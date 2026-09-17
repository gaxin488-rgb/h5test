#!/usr/bin/env escript
%%! -noshell
-mode(compile).

main([Baseline, Candidate]) ->
    try
        verify(Baseline, Candidate),
        halt(0)
    catch
        Class:Reason ->
            io:format(standard_error, "VERIFY_FAIL class=~p reason=~p~n", [Class, Reason]),
            halt(32)
    end;
main(_) ->
    io:format(standard_error, "usage: gift_39053_verify_patch.escript <baseline.beam> <candidate.beam>~n", []),
    halt(30).

verify(Baseline, Candidate) ->
    true = filelib:is_file(Baseline),
    true = filelib:is_file(Candidate),
    true = code:add_patha(filename:dirname(Baseline)),

    {beam_file, gift_data, ExportsBase, AttrsBase, _InfoBase, FuncsBase} = beam_disasm:file(Baseline),
    {beam_file, gift_data, ExportsCandidate, AttrsCandidate, _InfoCandidate, FuncsCandidate} = beam_disasm:file(Candidate),

    true = (ExportsBase =:= ExportsCandidate),
    true = (AttrsBase =:= AttrsCandidate),

    NormalBase = [normalize_function(F) || F <- FuncsBase],
    NormalCandidate = [normalize_function(F) || F <- FuncsCandidate],
    true = (NormalBase =:= NormalCandidate),
    io:format("STRUCTURAL_EQ_OUTSIDE_TARGET=true~n", []),

    GetCode = get_function_code(FuncsCandidate, get, 1),
    RandCode = get_function_code(FuncsCandidate, rand_list, 1),
    GetBlock = target_block(strip_lines(GetCode), 83),
    RandBlock = target_block(strip_lines(RandCode), 1131),

    ExpectedName = <<231,178,190,232,139,177,229,143,172,229,148,164,231,164,188,229,140,133>>,
    ExpectedGet = [
        {label,83},
        {allocate,0,0},
        {move,{literal,ExpectedName},{x,0}},
        {call_ext,1,{extfunc,lang,get,1}},
        {test_heap,13,1},
        {put_tuple,12,{x,1}},
        {put,{atom,gift_data}},
        {put,{integer,39053}},
        {put,{x,0}},
        {put,nil},
        {put,{literal,[{22,1000000}]}},
        {put,nil},
        {put,{integer,0}},
        {put,{integer,0}},
        {put,{integer,0}},
        {put,{integer,0}},
        {put,nil},
        {put,{integer,0}},
        {move,{x,1},{x,0}},
        {deallocate,0},
        return
    ],
    true = (GetBlock =:= ExpectedGet),
    true = (RandBlock =:= [{label,1131},{move,nil,{x,0}},return]),
    io:format("TARGET_BLOCKS_EXACT=true~n", []),

    {ok, Bin} = file:read_file(Candidate),
    {module, gift_data} = code:load_binary(gift_data, Candidate, Bin),
    G = gift_data:get(39053),
    R = gift_data:rand_list(39053),
    case {G, R} of
        {{gift_data,39053,_,[],[{22,1000000}],[],0,0,0,0,[],0}, []} ->
            io:format("TARGET_SEMANTICS_OK=true~n", []),
            ok;
        Other ->
            erlang:error({target_semantics_bad, Other})
    end.

normalize_function({function, get, 1, Entry, Code}) ->
    {function, get, 1, Entry, mask_block(strip_lines(Code), 83)};
normalize_function({function, rand_list, 1, Entry, Code}) ->
    {function, rand_list, 1, Entry, mask_block(strip_lines(Code), 1131)};
normalize_function({function, Name, Arity, Entry, Code}) ->
    {function, Name, Arity, Entry, strip_lines(Code)}.

strip_lines(Code) ->
    [I || I <- Code, not is_line(I)].

is_line({line, _}) -> true;
is_line(_) -> false.

get_function_code([{function, Name, Arity, _Entry, Code} | _], Name, Arity) ->
    Code;
get_function_code([_ | Rest], Name, Arity) ->
    get_function_code(Rest, Name, Arity);
get_function_code([], Name, Arity) ->
    erlang:error({function_not_found, Name, Arity}).

mask_block(Code, Label) ->
    {Before, FromLabel} = split_before_label(Code, Label, []),
    {_Block, After} = take_label_block(FromLabel, Label),
    Before ++ [{label,Label},{comment,target_mask}] ++ After.

target_block(Code, Label) ->
    {_Before, FromLabel} = split_before_label(Code, Label, []),
    {Block, _After} = take_label_block(FromLabel, Label),
    Block.

split_before_label([{label, Label} | _] = Rest, Label, Acc) ->
    {lists:reverse(Acc), Rest};
split_before_label([H | T], Label, Acc) ->
    split_before_label(T, Label, [H | Acc]);
split_before_label([], Label, _Acc) ->
    erlang:error({target_label_not_found, Label}).

take_label_block([{label, Label} = H | T], Label) ->
    take_until_next_label(T, [H]);
take_label_block(_, Label) ->
    erlang:error({invalid_target_block, Label}).

take_until_next_label([{label, _} | _] = Rest, Acc) ->
    {lists:reverse(Acc), Rest};
take_until_next_label([H | T], Acc) ->
    take_until_next_label(T, [H | Acc]);
take_until_next_label([], Acc) ->
    {lists:reverse(Acc), []}.
