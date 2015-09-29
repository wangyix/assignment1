

REGEX_COMPILE = false

local regex = require 'regex'

-------------------------------------------------------------------------------

local function randint(max)
  return math.floor((max+1)*math.random())
end
local function randDigit()
  return string.char(48+math.floor(10*math.random()))
end
local function randDigits(N)
  local s = ''
  for k=1,N do s = s .. randDigit() end
  return s
end

-------------------------------------------------------------------------------

local function randCapital()
  return string.char(65+math.floor(26*math.random()))
end
-- this function is recursive to avoid pathological garbage collector behavior
local function randAlphaString( nbytes )
  if nbytes < 32 then
    local s = ''
    for k=1,nbytes do s = s .. randCapital() end
    return s
  else
    local nleft = math.floor(nbytes/2)
    local nright = nbytes - nleft
    return randAlphaString(nleft) .. randAlphaString(nright)
  end
end

print('Preparing random test strings')
local MAX_EXP = 20
local randstrs = {}
for k=1,MAX_EXP do randstrs[k] = randAlphaString(math.pow(2,k)) end
print('Done Preparing random test strings\n')

-------------------------------------------------------------------------------

print('Preparing random CSV "files"')
local MAX_LINE_EXP = 12
local MAX_COMMAS = 10
local csvstrs = {}
local function randCSVFile( nlines, ncomma )
  if nlines == 1 then
    local flip = math.random()
        if flip < 0.04 then return '\n'
    elseif flip < 0.05 then return '# '..randAlphaString( randint(70) )..'\n'
    else
      local s = ''
      if math.random() < 0.25 then s=string.rep(' ', randint(5)) end
      s=s..randDigits(randint(6)+1)

      for k=1,ncomma do
        if math.random() < 0.2 then s=s..string.rep(' ', randint(5)) end
        s=s..','
        if math.random() < 0.2 then s=s..string.rep(' ', randint(5)) end
        s=s..randDigits(randint(10)+1)
      end

      if math.random() < 0.25 then s=string.rep(' ', randint(5)) end
      return s..'\n'
    end
  else
    local nleft   = math.floor(nlines/2)
    local nright  = nlines - nleft
    return randCSVFile( nleft, ncomma ) .. randCSVFile( nright, ncomma )
  end
end
for ncomma=1,MAX_COMMAS do
  local sub = {}
  csvstrs[ncomma] = sub
  for k=1,MAX_LINE_EXP do sub[k] = randCSVFile( math.pow(2,k), ncomma ) end
end
print('Done Preparing random CSV data\n')

-------------------------------------------------------------------------------

local function timetest(name, f)
  print('running '..name..' ...')
  local starttime = terralib.currenttimeinseconds()
  f()
  local elapsed = terralib.currenttimeinseconds() - starttime
  print(name..' took '..tostring(elapsed*1e3)..' ms')
end

-------------------------------------------------------------------------------

--
-- Taken from RE2's internal benchmark
-- 

-- can't match the $ in random alphabetical text
local EASY0   = regex("ABCDEFGHIJKLMNOPQRSTUVWXYZ$")
local EASY1   = regex("A[AB]B[BC]C[CD]D[DE]E[EF]F[FG]G[GH]H[HI]I[IJ]J$")
local MEDIUM  = regex("[XYZ]ABCDEFGHIJKLMNOPQRSTUVWXYZ$")
local HARD    = regex("[ -~]*ABCDEFGHIJKLMNOPQRSTUVWXYZ$")

timetest('EASY0', function()
  for _,str in ipairs(randstrs) do EASY0:find(str) end
end)
timetest('EASY1', function()
  for _,str in ipairs(randstrs) do EASY1:find(str) end
end)
timetest('MEDIUM', function()
  for _,str in ipairs(randstrs) do MEDIUM:find(str) end
end)
timetest('HARD', function()
  for _,str in ipairs(randstrs) do HARD:find(str) end
end)

-------------------------------------------------------------------------------

-- CSV PATTERN TESTS
local CSVLINE = {}
for k=1,MAX_COMMAS do
  local ptnstr = ' *%d%d*'
  for i=1,k do ptnstr = ptnstr .. ' *, *%d%d*' end
  ptnstr = ptnstr..' *\n'
  CSVLINE[k] = regex(ptnstr)
end

timetest('CSV', function()
  for nc=1,MAX_COMMAS do
    for _,str in ipairs(csvstrs[nc]) do
      local i,old=0,0
      while i and i < #str do
        old,i = CSVLINE[nc]:find(str, i)
      end
    end
  end
end)



