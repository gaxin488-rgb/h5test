#!/usr/bin/env escript
%%! -noshell

main([Prod, Out]) ->
    try
        build(Prod, Out),
        halt(0)
    catch
        Class:Reason ->
            io:format(standard_error, "BUILD_FAIL class=~p reason=~p~n", [Class, Reason]),
            halt(31)
    end;
main(_) ->
    io:format(standard_error, "usage: gift_39053_build_patch.escript <production.beam> <output.beam>~n", []),
    halt(30).

build(Prod, Out) ->
    {beam_file, gift_data, LabeledExports, Attrs, CompInfo, Functions0} = beam_disasm:file(Prod),
    {ok, {gift_data, [{"Code", CodeBin}]}} = beam_lib:chunks(Prod, ["Code"]),
    <<_SubSize:32, _Format:32, _HighestOpcode:32, NumLabels:32, _NumFuncs:32, _/binary>> = CodeBin,

    Exports = [{Name, Arity} || {Name, Arity, _Label} <- LabeledExports],
    Functions1 = [strip_lines(F) || F <- Functions0],
    {Functions2, GetCount, RandCount} = patch_functions(Functions1, [], 0, 0),
    true = (GetCount =:= 1),
    true = (RandCount =:= 1),

    Source = proplists:get_value(source, CompInfo, []),
    Opts = proplists:get_value(options, CompInfo, []),
    {ok, Beam} = beam_asm:module({gift_data, Exports, Attrs, Functions2, NumLabels}, <<>>, Source, Opts),
    ok = file:write_file(Out, Beam),
    io:format("BUILD_OK output=~s bytes=~p get_patches=~p rand_patches=~p~n",
              [Out, byte_size(Beam), GetCount, RandCount]).

strip_lines({function, Name, Arity, Entry, Code}) ->
    {function, Name, Arity, Entry, [I || I <- Code, not is_line(I)]}.

is_line({line, _}) -> true;
is_line(_) -> false.

patch_functions([], Acc, GetCount, RandCount) ->
    {lists:reverse(Acc), GetCount, RandCount};
patch_functions([{function, get, 1, Entry, Code0} | Rest], Acc, GetCount, RandCount) ->
    Code = replace_block(Code0, 83, fun patch_get_block/1),
    patch_functions(Rest, [{function, get, 1, Entry, Code} | Acc], GetCount + 1, RandCount);
patch_functions([{function, rand_list, 1, Entry, Code0} | Rest], Acc, GetCount, RandCount) ->
    Code = replace_block(Code0, 1131, fun patch_rand_block/1),
    patch_functions(Rest, [{function, rand_list, 1, Entry, Code} | Acc], GetCount, RandCount + 1);
patch_functions([F | Rest], Acc, GetCount, RandCount) ->
    patch_functions(Rest, [F | Acc], GetCount, RandCount).

replace_block(Code, Label, PatchFun) ->
    {Before, FromLabel} = split_before_label(Code, Label, []),
    {Block, After} = take_label_block(FromLabel, Label),
    Before ++ PatchFun(Block) ++ After.

split_before_label([{label, Label} | _] = Rest, Label, Acc) ->
    {lists:reverse(Acc), Rest};
split_before_label([H | T], Label, Acc) ->
    split_before_label(T, Label, [H | Acc]);
split_before_label([], Label, _Acc) ->
    erlang:error({target_label_not_found, Label}).

take_label_block([{label, Label} = H | T], Label) ->
    take_until_next_label(T, [H]);
take_label_block(_, Label) ->
    erlang:error({invalid_label_block, Label}).

take_until_next_label([{label, _} | _] = Rest, Acc) ->
    {lists:reverse(Acc), Rest};
take_until_next_label([H | T], Acc) ->
    take_until_next_label(T, [H | Acc]);
take_until_next_label([], Acc) ->
    {lists:reverse(Acc), []}.

patch_get_block(Block) ->
    ExpectedName = <<231,178,190,232,139,177,229,143,172,229,148,164,231,164,188,229,140,133>>,
    ExpectedOld = [
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
        {put,nil},
        {put,nil},
        {put,{integer,0}},
        {put,{integer,0}},
        {put,{integer,1}},
        {put,{integer,0}},
        {put,nil},
        {put,{integer,0}},
        {move,{x,1},{x,0}},
        {deallocate,0},
        return
    ],
    true = (Block =:= ExpectedOld),
    [
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
    ].

patch_rand_block(Block) ->
    true = lists:member({put,{integer,39053}}, Block),
    true = (count_instruction({put,{integer,39053}}, Block) =:= 4),
    true = lists:member({put,{integer,9000}}, Block),
    true = lists:member({put,{integer,700}}, Block),
    true = lists:member({put,{integer,295}}, Block),
    true = lists:member({put,{integer,5}}, Block),
    [{label,1131},{move,nil,{x,0}},return].

count_instruction(I, List) ->
    length([ok || X <- List, X =:= I]).
