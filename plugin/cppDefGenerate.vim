vim9script

def ParseWhitespace(str: string, idx: number): number
	var ret = idx
	while true
		if str[ret] != " " && str[ret] != "\t" && str[ret] != "\n" && str[ret] != "\r"
			break
		endif
		ret += 1
	endwhile
	return ret
enddef

def GenerateCppDefForEach(lineno: number)
	var line = getline(lineno)
	var col = ParseWhitespace(line, 0)
	var retTypeName = ""
	var functionName = ""
	var argName = ""
	var className = ""
	while true
		if line[col] != " " && line[col] != "\t" && line[col] != "\n" && line[col] != "\r" && line[col] != "("
			retTypeName = retTypeName .. line[col]
		else
			break
		endif
		col += 1
	endwhile

	if retTypeName == "virtual"
		retTypeName = ""
		col = ParseWhitespace(line, col)
		while true
			if line[col] != " " && line[col] != "\t" && line[col] != "\n" && line[col] != "\r" && line[col] != "("
				retTypeName = retTypeName .. line[col]
			else
				break
			endif
			col += 1
		endwhile
	endif

	if line[col] == "("
		functionName = retTypeName
		retTypeName = ""
	else
		col = ParseWhitespace(line, col)
		while true
			if line[col] != " " && line[col] != "\t" && line[col] != "\n" && line[col] != "\r" && line[col] != "("
				functionName = functionName .. line[col]
			else
				break
			endif
			col += 1
		endwhile
	endif

	col = ParseWhitespace(line, col)
	while true
		if line[col] != ";"
			argName = argName .. line[col]
		else
			break
		endif
		col += 1
	endwhile

	var current = lineno - 1
	var flag = false
	while current >= 1
		var sline = getline(current)
		if stridx(sline, "class ") != -1
			var ret = split(sline, " ")
			className = ret[1]
			flag = true
			break
		endif
		current -= 1
	endwhile
	
	if flag == true
		var generated = ""
		if retTypeName == ""
			generated = className .. "::" .. functionName .. argName .. " {\n\n}\n\n"
		else
			generated = retTypeName .. " " .. className .. "::" .. functionName .. argName .. " {\n\n}\n\n"
		endif
		@a = @a .. generated
	endif
enddef

def g:GenerateCppDef()
	@a = ""
	var start = getpos("'<")[1]
	var end = getpos("'>")[1]
	while start <= end
		GenerateCppDefForEach(start)
		start += 1
	endwhile	
enddef
