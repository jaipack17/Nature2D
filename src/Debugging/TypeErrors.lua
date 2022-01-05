-- Handling type errors

return function (arg: string, param, pos: number, expected: string)
	if typeof(param) ~= expected then
		error(
			string.format(
				"[Nature2D]: Invalid Argument #%s. Expected type %q for %s, got %q",
				tostring(pos),
				expected,
				arg,
				typeof(param)
			),
			2
		)
	end
end