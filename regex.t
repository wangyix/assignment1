
--[[

  CS448H Assignment 1: regular expression compiler

  This file is a skeleton of a complete regular expression language front-end,
  interpreter, and compiler. Your main work for this assignment is to complete
  the implementation of this file.
  
--]]

-- Extra Credit (highly optional, but fun!)
--  Can you optimize your regular expression compiler output further?

-- There's an opportunity to do an effective peephole optimization
--    during the NFA lowering because of how the parser unrolls
--    character classes.  Can you improve performance by doing this?

-- Suppose you wanted to add + to the regular expression syntax.
--    How much of the entire compiler/interpreter needs to change (minimum)?
--    Is there any good reason to change more parts of the compiler?
--  Try adding this feature.

-- We handled character classes by unrolling them in the parser.
--    This tends to create excessively large ASTs.  Can we improve
--    efficiency of character classes by adding a new kind of AST node?
--    If you try to do this, stop and think. 
--    Is there some simple, uniform, and normalized representation
--    you can use for all character classes?
--    Is there a particularly efficient way to compile character classes?
--    How do all the different compiler representations need to change?

-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--      AST Definition
-------------------------------------------------------------------------------

local AST = {}
AST.__index = AST

local REChar  = setmetatable({},AST)
local RESeq   = setmetatable({},AST)
local REOr    = setmetatable({},AST)
local REStar  = setmetatable({},AST)
local REMaybe = setmetatable({},AST)
REChar.__index  = REChar 
RESeq.__index   = RESeq  
REOr.__index    = REOr   
REStar.__index  = REStar 
REMaybe.__index = REMaybe

local function newREChar( charcode )
  return setmetatable({
    token = charcode
  }, REChar)
end
local function newRESeq( terms )
  assert(terralib.israwlist(terms), 'seq should take a list')
  return setmetatable({
    terms = terms,
  }, RESeq)
end
local function newREOr( terms )
  return setmetatable({
    terms = terms,
  }, REOr)
end
local function newREStar( term )
  return setmetatable({
    term = term,
  }, REStar)
end
local function newREMaybe( term )
  return setmetatable({
    term = term,
  }, REMaybe)
end

function REChar:__tostring()
  return '['..self.token..']'
end
function RESeq:__tostring()
  local s = '('
  for i,t in ipairs(self.terms) do
    if i > 1 then s = s..';' end
    s=s..tostring(t)
  end
  return s..')'
end
function REOr:__tostring()
  local s = '('
  for i,t in ipairs(self.terms) do
    if i > 1 then s = s..'|' end
    s=s..tostring(t)
  end
  return s..')'
end
function REStar:__tostring()
  return '('..tostring(self.term) ..')*'
end
function REMaybe:__tostring()
  return '('..tostring(self.term) ..')?'
end

-------------------------------------------------------------------------------
--      NFA Definition
-------------------------------------------------------------------------------

local NFA         = {}
local NFANode     = {}
local NFACharEdge = {} -- edge labeled w/ a character
local NFAEpsEdge  = {} -- epsilon edge
NFA.__index         = NFA
NFANode.__index     = NFANode
NFACharEdge.__index = NFACharEdge
NFAEpsEdge.__index  = NFAEpsEdge

-- Epsilon Edges vs. Character Edges
--    In an NFA, we often want to allow our machine to
--  non-deterministically transition between states.  Often, we want
--  those transitions to happen *without* consuming an input character.
--  Epsilon Edges represent these kind of transitions, whereas
--  Character Edges ("labeled edges") represent transitions caused by
--  consuming a character.

local function newNFA( nodes, startnode, acceptnode )
  assert( terralib.israwlist(nodes), 'nodes should be a raw list' )
  assert( getmetatable(startnode) == NFANode )
  assert( getmetatable(acceptnode) == NFANode )
  return setmetatable({
    nodes   = nodes,
    start   = startnode,
    accept  = acceptnode,
    n_nodes = #nodes,
  }, NFA)
end
local function newNFANode()
  return setmetatable({
    cedges  = {},     -- character edges
    eedges  = {},     -- epsilon edges
    accepts = false,
    id      = nil,
  }, NFANode)
end
local function newNFACharEdge( points_to_node, token )
  return setmetatable({
    token = token,
    node  = points_to_node,
  }, NFACharEdge)
end
local function newNFAEpsEdge( points_to_node )
  return setmetatable({
    node  = points_to_node,
  }, NFAEpsEdge)
end

-- Helper methods
function NFANode:push_cedge( destination_node, token )
  table.insert(self.cedges, newNFACharEdge(destination_node, token))
end
function NFANode:push_eedge( destination_node )
  table.insert(self.eedges, newNFAEpsEdge(destination_node))
end

function NFANode:setid( id_num )
  self.id = id_num
end

-- Printing the NFA
function NFA:print()
  print('nodes')
  for i,n in ipairs(self.nodes) do
    print(i..':', n)
    for _,e in ipairs(n.cedges) do
      print('  '..tostring(e.token), tostring(e.node.id) )
    end
    for _,e in ipairs(n.eedges) do
      print('  nil', tostring(e.node.id) )
    end
  end
  print('start',  self.start.id)
  print('accept', self.accept.id)
end

-------------------------------------------------------------------------------
--      NFA Lowering
-------------------------------------------------------------------------------

-- PART 1

-- To start off read (or at least skim) the Russ Cox article here:
--    https://swtch.com/~rsc/regexp/regexp1.html
--  You don't need to worry about anything after
--  "Caching the NFA to build a DFA".  We don't expect you to compile
--  to DFAs at all.

--    In part 1 of this assignment, you will be implementing the lowering
-- step described in the Cox article. We've already supplied you with
-- an AST and NFA definitions, so you don't need to decide on how to
-- represent either of these things.  We also implemented a parser
-- and NFA simulator for you, so once you implment the NFA lowering
-- step, you'll be able to test and benchmark your (non-compiled)
-- version of Regexes.

--    In part 2 of this assignment, you will write the metaprogrammed
-- parts of the compiler to construct a Terra function that simulates the
-- NFA.  In particular, you will implement the step() function that
-- computes one (non-deterministic) step of the NFA.  You can read the
-- Cox article to understand the general strategy and the inline comments
-- below for details



-- The lowering should produce an NFA from the regular expression
local function regex_to_nfa( re )

  -- TODO: (Part 1) WRITE YOUR CONVERSION FROM AST TO NFA HERE
  assert(false, "TODO: IMPLEMENT ME")

  -- HINT: You may find it easier to write your lowering pass in
  --        2 stages.  Stage 1 converts the regular expression to
  --        the NFA graph; Stage 2 assigns ids to and collects the set
  --        of nodes in the NFA graph.  You can merge these two stages,
  --        but separating them may simplify your thinking.

  -- TIP: When you write code to process a directed graph (i.e. the NFA)
  --      remember to use your CS 101 knowledge of graph-algorithms.
  --      You're going to need to implement little computations that
  --      do something similar to a recursive depth-first traversal,
  --      and you'll need some way to ensure termination.

  -- TIP: In a compiler, whenever you write a function to process
  --      an AST, you should expect to write a set of mutually-recursive
  --      tree traversal functions.  A good example in this file is
  --      the simple RE:__tostring() functions above.  You should expect
  --      that this regex to NFA conversion will also require some
  --      similarly "structurally recursive" function of the AST.

  return newNFA( --[[ pass arguments here ]] )
end

-------------------------------------------------------------------------------
--      NFA Simulation
-------------------------------------------------------------------------------

local function emptystate(N)
  local s = {}
  for k=1,N do s[k] = false end
  return s
end

function NFA:find( str, start_idx )
  local nfa = self
  local N   = nfa.n_nodes

  local function printstate(state)
    local s = ''
    for k=1,N do s=s..(state[k] and '1' or '0') end
    print(s)
  end

  local function mark(state, node)
    if state[node.id] then return end -- only mark once
    state[node.id] = true
    -- transitively mark everything implied by epsilon edges
    for _,e in ipairs(node.eedges) do mark(state, e.node) end
  end

  local function reset(state)
    for k=1,N do state[k] = false end
    mark(state, nfa.start)
  end

  local function accepts(state)
    return state[nfa.accept.id]
  end

  -- ******* This is the function that computes the NFA
  --          Transition Function
  -- returns nextstate, early_exit
  local function step(currstate, charcode)
    local nextstate   = emptystate(N)
    local early_exit  = true

    for i=1,N do
      -- Are we in state i?
      if currstate[i] then
        local cedges = nfa.nodes[i].cedges
        for _,e in ipairs(cedges) do
          -- Should we transition along this edge?
          if e.token == charcode then
            early_exit = false
            mark(nextstate, e.node)
          end
        end
      end
    end

    return nextstate, early_exit
  end

  -- Initialize the state
  local currstate = emptystate(N)
  reset(currstate)
  -- edge case
  if accepts(currstate) then return start_idx, start_idx end

  -- Do the find loop;
  --  Run a forward simulation of the NFA starting at each index
  for start_match = start_idx+1, #str do -- adjust 0 indexing
    reset(currstate)
    for i = start_match, #str do
      local charcode = string.byte(str, i)
      local early_exit
      -- Take a step of the NFA
      currstate, early_exit = step(currstate, charcode)
      if early_exit then break end -- try next starting position
      if accepts(currstate) then
        -- Success!
        return start_match-1, i -- adjust back to 0-indexing
      end
    end
  end

  -- We failed to find a match, so return nil
  return nil, nil
end

-------------------------------------------------------------------------------
--      NFA Compilation
-------------------------------------------------------------------------------

local C = terralib.includecstring([[
#include <stdlib.h>
#include <stdio.h>
]])

local FIND_FAIL = 2^32-1

function NFA:compile()
  local nfa = self
  local N   = nfa.n_nodes

  local State = &bool

  local terra printstate( s : State )
    for k=0,N do
      if s[k] then C.printf('1')
              else C.printf('0') end
    end
    C.printf('\n')
  end

  local terra zero( s : State )
    for k=0,N do s[k] = false end
  end

  local terra swap( a : &State, b : &State )
    var tmp = @a
    @a = @b
    @b = tmp
  end

  --    Suppose we decide during the step() computation that the machine
  -- should transition to the state for 'node'.  mark(state) can be called
  -- instead to ensure we mark all of the nodes transitively reachable
  -- from the first node due to epsilon edges.  Unlike the simulator version
  -- of mark(state), (see previous code) this version is going to
  -- generate specialized Terra functions that have pre-computed the
  -- set of transitively reachable nodes.
  --    One common pattern you will see in compiler is caching
  -- (aka. memo-izing) pieces of generated code to prevent needless
  -- duplication.  The skeleton code for genmark() includes memoization
  -- of the result for each node.
  local genmark_cache = {}
  local function genmark(node)
    if genmark_cache[node] then return genmark_cache[node] end

    -- Here we want to construct a mark() function as described in the
    -- last comment.  For instance, suppose we have an NFA for the
    -- regular expression 'a*bc*d' with the following transitions:
    --  state 0:
    --      a     0
    --      eps   1
    --  state 1:
    --      b     2
    --  state 2:
    --      c     2
    --      eps   3
    --  state 3:
    --      d     4
    --  state 4:
    --
    -- Then the mark function for state 1 should look like
    -- 
    --    terra mark( s : State )
    --      s[1] = true
    --    end
    -- 
    -- and the mark function for state 2 should look like
    --
    --    terra mark( s : State )
    --      s[2] = true
    --      s[3] = true
    --    end
    --

    -- TIP: Before you start metaprogramming the mark function,
    --      you should separately compute the set of nodes
    --      transitively reachable by epsilon edges (in Lua)

    -- TIP: In order to metaprogram this function you will probably need
    --      to represent at least one variable with a symbol object

    -- TIP: For an example of how genmark(node) is used, look at the
    --      definition of reset() below

    -- TODO: (Part 2) WRITE YOUR METAPROGRAMMED MARK FUNCTION HERE
    assert(false, "TODO: IMPLEMENT ME")

    local mark = nil -- replace with a function definition

    -- cache the generated function for future calls
    genmark_cache[node] = mark
    return mark
  end

  local mark_start = genmark(nfa.start)
  local terra reset( s : State )
    zero(s)
    mark_start(s)
  end

  local terra accepts( s : State )
    return s[ [nfa.accept.id-1] ]
  end

  -- You need to metaprogram a step function that looks something like
  -- the following:
  --
  --  local terra step(
  --    currstate : State, nextstate : State, charcode : int8
  --  ) : bool
  --
  --    if currstate[0] then
  --      if charcode == 23 then [genmark(23, nextstate)] end
  --      if charcode == 64 then [genmark(64, nextstate)] end
  --      ...
  --    end
  --    if currstate[1] then
  --      ...
  --    end
  --    ...
  --
  --    Step 1: You need to figure out how to metaprogram that code
  -- 
  --    -- useful for debugging
  --    printstate(currstate)
  --
  --    return false
  --    -- By default we return false, which tells the calling code
  --    -- not to early exit matching the current string.
  --    -- If we want to terminate this execution of the NFA and move
  --    -- on to trying substrings starting at the next index in the
  --    -- input, we should return true to signal 'early_exit'
  -- 
  --    Step 2: If you want to run efficiently, you need to somehow
  --              set early_exit when the state vector has become
  --              all false
  --  end

  -- TODO: (Part 2) WRITE YOUR METAPROGRAMMED STEP FUNCTION HERE
  assert(false, "TODO: IMPLEMENT ME")
  local step = nil -- replace with function definition

  -- Tip: You can use C.printf(...) and printstate(some_state)
  --      To help debug the execution of your metaprogrammed function

  -- Tip: You can print out your metaprogrammed function with the
  --      following line.  This is a good way to check whether or not
  --      you're generating the code you think you're generating.
  --step:printpretty()

  local terra find( str : rawstring, strlen : uint32, start_idx : uint32 )
    var currstate : State = [State](C.malloc( N * sizeof(bool) ))
    var nextstate : State = [State](C.malloc( N * sizeof(bool) ))
    reset(currstate)
    --C.printf('Init State\n')
    --printstate(currstate)
    --C.printf('\n')

    -- edge case where RE accepts empty string
    if accepts(currstate) then
      C.free(currstate); C.free(nextstate)
      return start_idx, start_idx
    end

    for start_match = start_idx, strlen do
      reset(currstate)
      --C.printf('RESET\n')

      for i = start_match, strlen do
        var charcode : int8 = str[i]

        -- Take a Step of the NFA
        zero(nextstate)
        var early_exit = step(currstate, nextstate, charcode)
        swap(&currstate, &nextstate)

        if early_exit then break end -- try next starting position
        if accepts(currstate) then
          C.free(currstate); C.free(nextstate)
          return start_match, i+1
        end
      end
    end

    -- return failure if we didn't find a match
    return FIND_FAIL, FIND_FAIL
  end

  return find
end

-------------------------------------------------------------------------------
--      Parser
-------------------------------------------------------------------------------

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

  -- helpers for doing character class unrolling
  local function genrange(lower, upper)
    local t = {}
    for k=lower,upper do
      table.insert(t, newREChar(k))
    end
    return newREOr(t)
  end

  local Abyte = string.byte('A',1)
  local abyte = string.byte('a',1)
  local Zbyte = string.byte('Z',1)
  local zbyte = string.byte('z',1)
  local byte0 = string.byte('0',1)
  local byte9 = string.byte('9',1)

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

    local c = str:sub(i,i)

    if     c == '.' then return genrange(0,127), i+1
    elseif c == '[' then
      local open_i = i
      c,i = str:sub(i+1,i+1),i+1
      local negate = ( c == '^' )
      if negate then i = i+1 end

      local ctbl = {}

      c,i = str:sub(i,i),i+1
      while c ~= ']' and i <= #str do
        if SHORTLIST[c] then 
        elseif c == '%' then
          c,i = str:sub(i,i),i+1
          if i >= #str then break end
          if      c == 'w' then
            for k=abyte,zbyte do ctbl[k] = true end
            for k=Abyte,Zbyte do ctbl[k] = true end
            for k=byte0,byte9 do ctbl[k] = true end
          elseif  c == 'a' then
            for k=abyte,zbyte do ctbl[k] = true end
            for k=Abyte,Zbyte do ctbl[k] = true end
          elseif  c == 'd' then
            for k=byte0,byte9 do ctbl[k] = true end
          else
            ctbl[ string.byte(c) ] = true
          end
        else
          ctbl[ string.byte(c) ] = true
        end

        c,i = str:sub(i,i),i+1
      end
      if c ~= ']' then
        error('missing closing ] for [ at '..open_i)
      end

      if negate then
        for i=0,127 do ctbl[i] = not ctbl[i] end
      end

      -- generate char and or
      local cexprs = {}
      for i=0,127 do if ctbl[i] then
        table.insert( cexprs, newREChar(i) )
      end end
      assert(#cexprs > 0)
      return newREOr(cexprs), i
    elseif SHORTLIST[c] then
      return nil, i -- reached delimiter...
    elseif c == '%' then
      c = str:sub(i+1,i+1)
      if     c == 'd' then return genrange(byte0, byte9), i+2
      elseif c == 'a' then return newREOr({
                                    genrange(abyte, zbyte),
                                    genrange(Abyte, Zbyte),
                                  }), i+2
      elseif c == 'w' then return newREOr({
                                    genrange(abyte, zbyte),
                                    genrange(Abyte, Zbyte),
                                    genrange(byte0, byte9),
                                  }), i+2
      else
        return newREChar( string.byte(c, 1) ), i+2
      end
    else
      return newREChar( string.byte(c, 1) ), i+1
    end
  end

  function parseseq(str, i)
    local nodeseq = {}

    while i <= #str do
      local c = str:sub(i,i)

      if c == '*' then
        local prevnode = nodeseq[#nodeseq]
        if not prevnode then error('* did not come after anything: '..i) end
        local newnode = newREStar(prevnode)
        nodeseq[#nodeseq] = newnode
        i = i + 1
      elseif c == '?' then
        local prevnode = nodeseq[#nodeseq]
        if not prevnode then error('? did not come after anything: '..i) end
        local newnode = newREMaybe(prevnode)
        nodeseq[#nodeseq] = newnode
        i = i + 1
      elseif c == '|' then
        if #nodeseq == 0 then error('nothing before |: '..i) end
        local leftnode      = newRESeq(nodeseq)
        local rightnode, ni = parseseq(str, i+1)
        local choicenode    = newREOr({ leftnode, rightnode })
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
        i = ni
      end
    end

    assert(#nodeseq > 0)
    local seqnode = newRESeq(nodeseq)
    return seqnode, i
  end


  -- Lua indexing starts at 1
  local re, final_i = parseseq(parsestr, 1)
  if final_i ~= #parsestr+1 then
    error('regex was malformed; only parsed up to '..final_i)
  end

  return re
end

-------------------------------------------------------------------------------
--      Regex Object
-------------------------------------------------------------------------------

-- Build a regex and return an object with a find function
local function regex( pattern_string )
  local re  = parse_regex(pattern_string)
  --print(re)
  local nfa = regex_to_nfa(re)
  local find
  if REGEX_COMPILE then
    local tfunc = nfa:compile()
    tfunc:compile() -- force compilation here rather than in test
    function find(self, str, start_idx)
      start_idx = start_idx or 0
      local r = tfunc(str, #str, start_idx)
      if r._0 == FIND_FAIL then return nil,nil
                           else return r._0, r._1 end
    end
  else
    function find(self, str, start_idx)
      start_idx = start_idx or 0
      return nfa:find(str, start_idx)
    end
  end

  return {
    re    = re,
    nfa   = nfa,
    find  = find,
  }
end

-------------------------------------------------------------------------------

-- This binds the function regex into the module system
-- You don't really need to understand this part of Lua
-- for this assignment at all
package.loaded['regex'] = regex
