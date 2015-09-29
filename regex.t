
--[[

  We put together this skeleton code to illustrate how your
  regex implemenation should interact with a test code harness.
  Please conform to the interface given by the function regex() at the
  end of this file.
  
--]]

-------------------------------------------------------------------------------

-- Project First Half: (Lua Interpreter)
--  1.  Finish implementing the Parser below
--  2.  Generate an NFA representation of the RegEx
--        ( 2 options: directly generate the NFA from the parser
--                 OR  build an AST from the parser, then convert to NFA )
--  3.  Implement an NFA simulation in Lua

-- Check Yourself!
--  Are you passing all the `testregex.t` tests?
--  In the reference (Lua) implementation, all the tests in `perfregex.t`
--    run in less than 10 seconds on a new Macbook 1.3 GHz processor.
--    (3-6 seconds I think)  You probably shouldn't be running much slower.

-- How Do I Implement an NFA?
--  Read this article by Russ Cox
--    https://swtch.com/~rsc/regexp/regexp1.html
--  You don't need to worry about anything after
--  "Caching the NFA to build a DFA".  We don't expect you to try to compile
--  to DFAs at all.

-- Notes:

-------------------------------------------------------------------------------

-- Project Second Half: (Compile to Terra)
--  1.  Code generate a Terra function to simulate the NFA

-- The main step in simulating an NFA is computing a state transition
-- function.  Think about: How can I code generate this function by
-- metaprogramming Terra?  How should I encode the state?

-- Check Yourself!
--  Are you passing all the `testregex.t` tests?
--  Your Terra implemenation should probably be at least 10x faster than Lua,
--    especially for the first 4 performance tests (CSV may be harder?)

-- Notes:

-------------------------------------------------------------------------------

-- Extra Credit
--  Can you optimize your regular expression compiler output further?

-------------------------------------------------------------------------------

-- The following is a skeleton for a regex parser.
-- We have not specified what sort of AST or intermediate representation
-- you should use.  That's up to you.

local SHORTLIST = {
  ['*'] = true,
  ['?'] = true,
  ['('] = true,
  [')'] = true,
  ['['] = true,
  [']'] = true,
  ['|'] = true,
  ['.'] = true,
  ['^'] = true,
}
local function parse_regex(parsestr)
  -- forward declare parser functions
  local parseatom, parseseq

  -- This function is not declared local
  -- because we already pre-declared it
  function parseatom(str, i)
    -- parse a character class here

    --    atom        = [ ^ char_sequence ]
    --                  [ char_sequence ]
    --                  simpatom
    --                  .
    --    char        = %w
    --                  %a
    --                  %d
    --                  % (any ASCII)
    --                  (any ASCII except those on the SHORTLIST above)
    -- 
    -- .  represents any character
    -- %a is alphabetical characters (lower and uppercase)
    -- %d is digits 0-9
    -- %w is %a and %d combined
    -- 
    -- NOTE: whitespace is NOT ignored in this regex syntax
    -- 

    local node = {} -- dummy for character class
                    -- generate an actual thing

    local c = str:sub(i,i)

        if c == '.' then return node, i+1
    elseif c == '[' then
      while c ~= ']' do c,i = str:sub(i+1,i+1), i+1 end
      return node, i+1
    elseif SHORTLIST[c] then
      return nil, i -- reached delimiter...
    elseif c == '%' then
      return node, i+2
    else
      return node, i+1
    end
  end

  function parseseq(str, i)
    local nodeseq = {}

    while i <= #str do
      local c = str:sub(i,i)

      if c == '*' then
        local prevnode = nodeseq[#nodeseq]
        if not prevnode then error('* did not come after anything: '..i) end
        local newnode = {} -- incorporate prevnode here?
        nodeseq[#nodeseq] = newnode
        i = i + 1
      elseif c == '?' then
        local prevnode = nodeseq[#nodeseq]
        if not prevnode then error('? did not come after anything: '..i) end
        local newnode = {} -- incorporate prevnode here?
        nodeseq[#nodeseq] = newnode
        i = i + 1
      elseif c == '|' then
        local leftnode      = nodeseq
        local rightnode, ni = parseseq(str, i+1)
        local choicenode    = {} -- build this somehow
        return choicenode, ni
      elseif c == '(' then
        local newnode, ni = parseseq(str, i+1)
        if not str:sub(ni,ni) == ')' then
          error('missing ) at '..ni..' for ( at '..i) end
        table.insert(nodeseq, newnode)
        i = ni + 1
      else -- ok, I guess it's an atom
        local atom, ni = parseatom(str,i)
        if not atom then -- ran into some delimiter
          i = ni
          break
        end
        table.insert(nodeseq, atom)
        i = ni + 1
      end
    end

    local nodefromseq = {}
    return nodefromseq, i
  end


  -- Lua indexing starts at 1
  local re, final_i = parseseq(parsestr, 1)
  if final_i ~= #parsestr+1 then
    error('regex was malformed; only parsed up to '..final_i)
  end

  return re
end



-------------------------------------------------------------------------------

-- This function should build a regex object.
-- This is your opportunity to compile or otherwise prepare the
-- regular expression for efficient execution on particular strings
local function regex( pattern_string )

  local data1 = 'The regex is being defined now:'
  local data2 = 'The regex is being executed on a string now:'

  -- build any additional data for the regex
  print(data1)
  print('  '..tostring(pattern_string))
  if REGEX_COMPILE then
    print('  Building Compiled Form')
  else
    print('  Building Interpreted Form')
  end

  -- This function is called whenever we want to execute the
  -- regex on a given string.  Using self, you can access any
  -- data that you've stored in the table returned by 'regex()'
  local find = function(self, str, start_index)
    start_index = start_index or 0
    print(self.data2)
    print('  '..tostring(pattern_string))
    print('  '..tostring(str))
    print('  starting at '..tostring(start_index))
    -- couldn't find it
    return nil, nil
    -- found the pattern starting before position 1
    -- and ending before position 3
    -- return 1, 3
  end

  return {
    data1 = data1,
    data2 = data2,
    find  = find,
  }
end

-------------------------------------------------------------------------------

-- This binds the function regex into the module system
-- You don't really need to understand this part of Lua
-- for this assignment at all
package.loaded['regex'] = regex

