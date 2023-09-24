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
	while true
		if line[col] != " " && line[col] != "\t" && line[col] != "\n" && line[col] != "\r"
			retTypeName = retTypeName .. line[col]
		else
			break
		endif
		col += 1
	endwhile

	col = ParseWhitespace(line, col)
	var functionName = ""
	while true
		if line[col] != " " && line[col] != "\t" && line[col] != "\n" && line[col] != "\r" && line[col] != "("
			functionName = functionName .. line[col]
		else
			break
		endif
		col += 1
	endwhile

	col = ParseWhitespace(line, col)
	var argName = ""
	while true
		if line[col] != ";"
			argName = argName .. line[col]
		else
			break
		endif
		col += 1
	endwhile

	var className = ""
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
		var generated = retTypeName .. " " .. className .. "::" .. functionName .. argName .. " {\n\n}\n\n"
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
