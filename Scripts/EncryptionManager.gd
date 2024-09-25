extends Node

const con1_to_bit : Array[String] = ["  ", "0 ", "1 ", " 0", " 1", "00", "01", "10", "11"]
const bit_to_con1 : Array[String] = ["a" , "b" , "c" , "d" , "e" , "f" , "g" , "h" , "i"]
const con1_to_con2 : Array[String] = ["aa", "ab", "ac", "ad", "ae", "af", "ag", "ah", "ai", "ba", "bb", "bc", "bd", "be", "bf", "bg", "bh", "bi", "ca", "cb", "cc", "cd", "ce", "cf", "cg", "ch", "ci", "da", "db", "bc", "dd", "de", "df", "dg", "dh", "di", "ea", "eb", "ec", "ed", "ee", "ef", "eg", "eh", "ei", "fa", "fb", "fc", "fd", "fe", "ff", "fg", "fh", "fi", "ga", "gb", "gc", "gd", "ge", "gf", "gg", "gh", "gi", "ha", "hb", "hc", "hd", "he", "hf", "hg", "hh", "hi", "ia", "ib", "ic", "id", "ie", "if", "ig", "ih", "ii"]
const con2_to_con1 : Array[String] = ["a" , "b" , "c" , "d" , "e" , "f" , "g" , "h" , "i" , "j" , "k" , "l" , "m" , "n" , "o" , "p" , "q" , "r" , "s" , "t" , "u" , "v" , "w" , "x" , "y" , "z" , "A" , "B" , "C" , "D" , "E" , "F" , "G" , "H" , "I" , "J" , "K" , "L" , "M" , "N" , "O" , "P" , "Q" , "R" , "S" , "T" , "U" , "V" , "W" , "X" , "Y" , "Z" , "0" , "1" , "2" , "3" , "4" , "5" , "6" , "7" , "8" , "9" , "!" , '"' , "£" , "$" , "%" , "^" , "&" , "*" , "(" , ")" , "-" , "_" , "+" , "=" , "[" , "]" , "{" , "}" , "@"]

func encrypt(input_string : String, key : String) -> String:
	var to_return : String = input_string
	to_return = str_to_bin(to_return)
	if (((int(key[0]) + int(key[1]) + int(key[2]) + int(key[3])) + 1) % 2) == 0:
		to_return = bit_flip(to_return)
	for i in range(0, (((int(key[1]) * int(key[3])) + 1) % 10)):
		to_return = bit_shift(to_return, ((int(key[0]) * int(key[3])) + 1), 0)
	for i in range(0, (((int(key[2]) * int(key[3])) + 1) % 10)):
		to_return = bit_shift(to_return, ((int(key[1]) * int(key[3])) + 1), 0)
		to_return = bit_reversal(to_return)
	to_return = bit_crunch(to_return, 0)
	if (((int(key[0]) + int(key[1]) + int(key[2]) * int(key[3])) + 1) % 2) == 0:
		to_return = to_return.reverse()
	return to_return

func decrypt(input_string : String, key : String) -> String:
	var to_return : String = input_string
	if (((int(key[0]) + int(key[1]) + int(key[2]) * int(key[3])) + 1) % 2) == 0:
		to_return = to_return.reverse()
	to_return = bit_crunch(to_return, 1)
	for i in range(0, (((int(key[2]) * int(key[3])) + 1) % 10)):
		to_return = bit_reversal(to_return)
		to_return = bit_shift(to_return, ((int(key[1]) * int(key[3])) + 1), 1)
	for i in range(0, (((int(key[1]) * int(key[3])) + 1) % 10)):
		to_return = bit_shift(to_return, ((int(key[0]) * int(key[3])) + 1), 1)
	if (((int(key[0]) + int(key[1]) + int(key[2]) + int(key[3])) + 1) % 2) == 0:
		to_return = bit_flip(to_return)
	to_return = bin_to_str(to_return)
	return to_return

func str_to_bin(input_str : String) -> String:
	var to_return : String = ""
	for item in input_str:
		to_return += str(String.num_uint64(item.unicode_at(0), 2)) + " "
	return to_return

func bin_to_str(input_bin : String) -> String:
	var to_return : String = ""
	var binary_input : PackedStringArray = input_bin.split(" ")
	while "" in binary_input:
		binary_input.remove_at(binary_input.find(""))
	for item in binary_input:
		to_return += String.chr(int(item.bin_to_int()))
	return to_return

func bit_flip(input_bin : String) -> String:
	var to_return : String = ""
	for item in input_bin:
		if item != " ":
			to_return += str(int(!bool(int(item))))
		else:
			to_return += " "
	return to_return

func bit_shift(input_bin : String, num : int, dir : int) -> String:
	var to_return : String = ""
	var binary_input : PackedStringArray = input_bin.split(" ")
	while "" in binary_input:
		binary_input.remove_at(binary_input.find(""))
	for i in range(0, len(binary_input)):
		var item : String = binary_input[i]
		if dir == 0:
			for i2 in range(0, (num % len(item))):
				item = (item[-1] + item.substr(0, len(item)-1))
		elif dir == 1:
			for i2 in range(0, (num % len(item))):
				item = (item.substr(1, -1) + item[0])
		binary_input[i] = item
	for item in binary_input:
		to_return += (item + " ")
	return to_return

func bit_reversal(input_bin : String) -> String:
	var to_return : String = ""
	var binary_input : PackedStringArray = input_bin.split(" ")
	var binary_output : Array[String] = []
	while "" in binary_input:
		binary_input.remove_at(binary_input.find(""))
	for item in binary_input:
		binary_output.append(item.reverse())
	for item in binary_output:
		to_return += (item + " ")
	return to_return

func bit_crunch(input : String, direction : int) -> String:
	var partialy_crunched : String = ""
	var to_return : String = ""
	var i : int = 0
	if direction == 0:
		if (len(input) % 2) != 0:
			input += " "
		while i < len(input):
			partialy_crunched += bit_to_con1[con1_to_bit.find((input[i] + input[i+1]))]
			i += 2
		if (len(partialy_crunched) % 2) != 0:
			partialy_crunched += bit_to_con1[con1_to_bit.find("  ")]
		i = 0
		while i < len(partialy_crunched):
			to_return += con2_to_con1[con1_to_con2.find((partialy_crunched[i] + partialy_crunched[i+1]))]
			i += 2
	elif direction == 1:
		while i < len(input):
			partialy_crunched += con1_to_con2[con2_to_con1.find(input[i])]
			i += 1
		i = 0
		while i < len(partialy_crunched):
			to_return += con1_to_bit[bit_to_con1.find(partialy_crunched[i])]
			i += 1
		if to_return[-2] == " ":
			to_return = to_return.left(-1)
	return to_return
