require_relative './environment'

class Brainfuck
  def initialize(input:, output:)
    @uninterpreted = input
    @interpreted = output
  end

  def interpret!(script)
    length = script.length 
    itr = 0
    # we use a stack and a hashmap to keep track of where to jump 
    # for the brackets 
    stack = []
    map = {}
    c = [0]

    for i in 0..length-1 do 
      case script[i]
        # creating a map between matching brackets using a stack 
        when ?[ then stack.push(i)
        when ?] then (map[stack.pop] = i)
      end 
    end 

    ptr = -1 

    until (ptr+=1) == length
      case script[ptr]
        # increment the pointer if the array value at the pointer is nil then we initialize to 0
        when ?> then (itr+=1) && c[itr].nil? && c[itr] = 0
        # decrement the pointer (ensure that the pointer value does not go below 0)
        when ?< then itr==0 ? itr = 0 : itr -= 1
        # UTF_8 apparently has a maximum value of 1112064 so we will loop the value around if it is 
        # too big or too small 
        when ?+ then c[itr] <= 1112063 ? c[itr]+=1 : c[itr]=0
        when ?- then c[itr] >= 1 ? c[itr] -=1 : c[itr]=1112064
        # if the byte at the pointer is zero jump forward to matching ]
        when ?[ then c[itr] == 0 && ptr = map[ptr]
        # if the byte at the pointer is not zero then jump backward to matching [
        when ?] then c[itr] !=0 && ptr = map.key(ptr)
        # Printing out the interpreted result by converting from int to char using UTF_8 encoding
        when ?. then "Testing #{c[itr].chr}" && @interpreted.print(c[itr].chr(Encoding::UTF_8))
        # input byte and store it in the byte at the pointer 
        when ?, then c[itr] = get_character.to_i
      end 
    end 

  end
end
