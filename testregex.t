
-- When you're ready to test your compiled version,
-- change this variable.
-- The variable is defined here to let test code test both implemenations.
REGEX_COMPILE = false

-- this is the function we exported from regex.t
local regex = require 'regex'

-------------------------------------------------------------------------------

local function E(restr, str, start,stop)
  print('testing: ', restr)
  print('  on     ', str)
  local re = regex(restr)
  local rstart, rstop = re:find(str)
  if rstart ~= start or rstop ~= stop then
    --print(re.re)
    --re.nfa:print()
    error('Test failed:\n'..
          restr..'\n'..
          str..'\n'..
          '  Expected '..tostring(start)..' '..tostring(stop)..'\n'..
          '  Got      '..tostring(rstart)..' '..tostring(rstop), 2)
  end
end

-------------------------------------------------------------------------------

-- Simple examples
E('hello', 'hello world', 0, 5) -- starts at 0 ends right before 5
E('hello', 'Oh Hi There', nil, nil) -- nil if not found
--          0123456789012345678901234567890
E('hello', 'You say goodbye, I say hello. hello, hello!', 23, 28)

-------------------------------------------------------------------------------

-- This set of test cases is adapted from an AT&T Test Set
-- source: http://www2.research.att.com/~astopen/testregex/basic.dat
--
E('abracadabra'               , 'abracaabracadabra'         ,  6, 17 )
E('a...b'                     , 'abababbb'                  ,  2,  7 )
E('XXXXXX'                    , '..XXXXXX'                  ,  2,  8 )
E('%)'                        , '()'                        ,  1,  2 )
E('a%]'                       , 'a]a'                       ,  0,  2 )
E('%}'                        , '}'                         ,  0,  1 )
E('%]'                        , ']'                         ,  0,  1 )
E('%['                        , '['                         ,  0,  1 )
E('{'                         , '{'                         ,  0,  1 )
E('}'                         , '}'                         ,  0,  1 )
E('a'                         , 'ax'                        ,  0,  1 )
E('%^a'                       , 'a^a'                       ,  1,  3 )
E('a%^'                       , 'a^'                        ,  0,  2 )
E('a'                         , 'aa'                        ,  0,  1 )
E('a$'                        , 'a$'                        ,  0,  2 )
E('a(a)'                      , 'aa'                        ,  0,  2 )
E('a*(a)'                     , 'aa'                        ,  0,  1 )
E('(..)*(...)*'               , 'a'                         ,  0,  0 )
E('(..)*(...)*.'              , 'abcd'                      ,  0,  1 )
E('((ab)|a)((bc)|c)'          , 'abc'                       ,  0,  3 )
E('((ab)c)|(abc)'             , 'abc'                       ,  0,  3 )
E('a*b'                       , 'ab'                        ,  0,  2 )
E('(a*)(b?)(bb*)bbb'          , 'aaabbbbbbb'                ,  0,  7 )
E('(a*)(b?)(bb*)bbba'         , 'aaabbbbbbba'               ,  0, 11 )
E('a'                         , ''                          ,nil,nil )
E('((a|a)|a)'                 , 'a'                         ,  0,  1 )
--
E('(a*)(a|aa)'                , 'aaaa'                      ,  0,  1 )
E('a*(a.|aa)'                 , 'aaaa'                      ,  0,  2 )
E('a(b)|c(d)|a(e)f'           , 'aef'                       ,  0,  3 )
E('(a|b)?.*'                  , 'b'                         ,  0,  0 )
E('(a|b)c|a(b|c)'             , 'ac'                        ,  0,  2 )
E('(a|b)c|a(b|c)'             , 'ab'                        ,  0,  2 )
E('(a|b)c|a(b|c)'             , 'bc'                        ,  0,  2 )
E('(a|b)c|a(b|c)'             , 'aa'                        ,nil,nil )
E('(a|b)*c|(a|ab)*c'          , 'abc'                       ,  0,  3 )
E('(a|b)*c|(a|ab)*c'          , 'xc'                        ,  1,  2 )
E('(.a|.b).*|.*(.a|.b)'       , 'xa'                        ,  0,  2 )
E('a?(ab|ba)ab'               , 'abab'                      ,  0,  4 )
E('a?(ab|ba)ab'               , 'baab'                      ,  0,  4 )
E('a?(ab|ba)ab'               , 'baaab'                     ,nil,nil )
E('ab|abab'                   , 'abbabab'                   ,  0,  2 )
E('aba|bab|bba'               , 'baaabbbaba'                ,  5,  8 )
E('aba|bab'                   , 'baaabbbaba'                ,  6,  9 )
E('(aa|aaa)*|(a|aaaaa)'       , 'aa'                        ,  0,  0 )
E('(a.|.a.)*|(a|.a...)'       , 'aa'                        ,  0,  0 )
E('ab|a'                      , 'xabc'                      ,  1,  2 )
E('ab|a'                      , 'xxabc'                     ,  2,  3 )
E('(Ab|cD)*'                  , 'aBcD'                      ,  0,  0 )
E('[^-]'                      , '--a'                       ,  2,  3 )
E('[a-]*[a-]'                 , '--a'                       ,  0,  1 )
E('[a-m-]*[a-m]'              , '--amoma--'                 ,  0,  1 )
E('[a-m-]*[^a-m]'             , '--amoma--'                 ,  0,  5 )
E('[a-m-]*[^a-m]'             , '--amdma--'                 ,  0,  5 )
E(':::1:::0:|:::1:1:0:'       , ':::0:::1:::1:::0:'         ,  8, 17 )
E(':::1:::0:|:::1:1:1:'       , ':::0:::1:::1:::0:'         ,  8, 17 )

E('\n'                        , '\n'                        ,  0,  1 )
E('[^a]'                      , '\n'                        ,  0,  1 )
E('[^a]'                      , 'a\n'                       ,  1,  2 )
E('\na'                       , '\na'                       ,  0,  2 )
E('(a)(b)(c)'                 , 'abc'                       ,  0,  3 )
E('xxx'                       , 'xxx'                       ,  0,  3 )

E('($|[ %(,;])((([Ff]eb[^ ]* *|0*2/|\\* */?)0*[67]))',
  '$feb 6,'        ,  0,  6 )
E('($|[ %(,;])((([Ff]eb[^ ]* *|0*2/|\\* */?)0*[67]))',
  '$2/7'           ,  0,  4 )
E('($|[ %(,;])((([Ff]eb[^ ]* *|0*2/|\\* */?)0*[67]))',
  '$feb 1,Feb 6'   ,  6, 12 )
E('((((((((((((((((((((((((((((((x))))))))))))))))))))))))))))))',
  'x'             ,  0,  1 )
E('((((((((((((((((((((((((((((((x))))))))))))))))))))))))))))))*',
  'xx'            ,  0,  0 )
E('a?(ab|ba)*X',
  'abababababababababababababababababababababababababababababab'..
  'ababababababababababaX'     ,  0, 82 )

E('abaa|abbaa|abbbaa|abbbbaa', 'ababbabbbabbbabbbbabbbbaa'  , 18, 25 )
E('abaa|abbaa|abbbaa|abbbbaa', 'ababbabbbabbbabbbbabaa'     , 18, 22 )
E('aaac|aabc|abac|abbc|baac|babc|bbac|bbbc', 'baaabbbabac'  ,  7, 11 )
E('aaaa|bbbb|cccc|ddddd|eeeeee|fffffff|gggg|hhhh|iiiii|jjjjj|kkkkk|llll',
  'XaaaXbbbXcccXdddXeeeXfffXgggXhhhXiiiXjjjXkkkXlllXcbaXaaaa', 53, 57 )
E('aaaa\nbbbb\ncccc\nddddd\neeeeee\nfffffff\ngggg\nhhhh\niiiii\njjjjj'..
  '\nkkkkk\nllll',
  'XaaaXbbbXcccXdddXeeeXfffXgggXhhhXiiiXjjjXkkkXlllXcbaXaaaa',nil,nil )

E('a*a*a*a*a*b'               , 'aaaaaaaaab'                ,  0, 10 )
E('a'                         , 'a'                         ,  0,  1 )
E('abc'                       , 'abc'                       ,  0,  3 )
E('abc'                       , 'xabcy'                     ,  1,  4 )
E('abc'                       , 'ababc'                     ,  2,  5 )
E('ab*c'                      , 'abc'                       ,  0,  3 )
E('ab*bc'                     , 'abc'                       ,  0,  3 )
E('ab*bc'                     , 'abbc'                      ,  0,  4 )
E('ab*bc'                     , 'abbbbc'                    ,  0,  6 )
E('abb*bc'                    , 'abbc'                      ,  0,  4 )
E('abb*bc'                    , 'abbbbc'                    ,  0,  6 )
E('ab?bc'                     , 'abbc'                      ,  0,  4 )
E('ab?bc'                     , 'abc'                       ,  0,  3 )
E('ab?c'                      , 'abc'                       ,  0,  3 )
E('abc'                       , 'abcc'                      ,  0,  3 )
E('abc'                       , 'aabc'                      ,  1,  4 )
E('a.c'                       , 'abc'                       ,  0,  3 )
E('a.c'                       , 'axc'                       ,  0,  3 )
E('a.*c'                      , 'axyzc'                     ,  0,  5 )
E('a[bc]d'                    , 'abd'                       ,  0,  3 )
E('a[bc]d'                    , 'acd'                       ,  0,  3 )
E('a[bcd]e'                   , 'ace'                       ,  0,  3 )
E('a[bcd]'                    , 'aac'                       ,  1,  3 )
E('a[-b]'                     , 'a-'                        ,  0,  2 )
E('a[b-]'                     , 'a-'                        ,  0,  2 )
E('a%]'                       , 'a]'                        ,  0,  2 )
E('a%]b'                      , 'a]b'                       ,  0,  3 )

E('a[^bc]d'                   , 'aed'                       ,  0,  3 )
E('a[^-b]c'                   , 'adc'                       ,  0,  3 )
E('a[^%]b]c'                  , 'adc'                       ,  0,  3 )
E('ab|cd'                     , 'abc'                       ,  0,  2 )
E('ab|cd'                     , 'abcd'                      ,  0,  2 )
E('a%(b'                      , 'a(b'                       ,  0,  3 )
E('a%(*b'                     , 'ab'                        ,  0,  2 )
E('a%(*b'                     , 'a((b'                      ,  0,  4 )
E('((a))'                     , 'abc'                       ,  0,  1 )
E('(a)b(c)'                   , 'abc'                       ,  0,  3 )
E('aa*bb*c'                   , 'aabbabc'                   ,  4,  7 )
E('a*'                        , 'aaa'                       ,  0,  0 )
E('(a*)*'                     , '-'                         ,  0,  0 )
E('(a*)(a*)*'                 , '-'                         ,  0,  0 )
E('(a*|b)*'                   , '-'                         ,  0,  0 )
E('(aa*|b)*'                  , 'ab'                        ,  0,  0 )
E('(aa*|b)(aa*|b)*'           , 'ab'                        ,  0,  1 )
E('(aa*|b)?'                  , 'ab'                        ,  0,  0 )
E('[^ab]*'                    , 'cde'                       ,  0,  0 )
E('(%^)*'                     , '-'                         ,  0,  0 )
E('a*'                        , ''                          ,  0,  0 )
E('([abc])*d'                 , 'abbbcd'                    ,  0,  6 )
E('([abc])*bcd'               , 'abcd'                      ,  0,  4 )
E('a|b|c|d|e'                 , 'e'                         ,  0,  1 )
E('(a|b|c|d|e)f'              , 'ef'                        ,  0,  2 )
E('((a*|b))*'                 , '-'                         ,  0,  0 )
E('abcd*efg'                  , 'abcdefg'                   ,  0,  7 )
E('ab*'                       , 'xabyabbbz'                 ,  1,  2 )
E('ab*'                       , 'xayabbbz'                  ,  1,  2 )
E('(ab|cd)e'                  , 'abcde'                     ,  2,  5 )
E('[abhgefdc]ij'              , 'hij'                       ,  0,  3 )
E('(a|b)c*d'                  , 'abcd'                      ,  1,  4 )
E('(ab|ab*)bc'                , 'abc'                       ,  0,  3 )
E('a([bc]*)c*'                , 'abc'                       ,  0,  1 )
E('a([bc]*)(c*d)'             , 'abcd'                      ,  0,  4 )
E('a([bc][bc]*)(c*d)'         , 'abcd'                      ,  0,  4 )
E('a([bc]*)(cc*d)'            , 'abcd'                      ,  0,  4 )
E('a[bcd]*dcdcde'             , 'adcdcde'                   ,  0,  7 )
E('(ab|a)b*c'                 , 'abc'                       ,  0,  3 )
E('((a)(b)c)(d)'              , 'abcd'                      ,  0,  4 )
E('[%a_][%w_]*'               , 'alpha'                     ,  0,  1 )
E('[%a_][%w_]*$'              , 'alpha$'                    ,  0,  6 )
E('a(bcc*|b[eh])g|.h'         , 'abh'                       ,  1,  3 )
E('(bcc*d|ef*g.|h?i(j|k))'    , 'effgz'                     ,  0,  5 )
E('(bcc*d|ef*g.|h?i(j|k))'    , 'ij'                        ,  0,  2 )
E('(bcc*d|ef*g.|h?i(j|k))'    , 'reffgz'                    ,  1,  6 )
E('multiple words'            , 'multiple words yeah'       ,  0, 14 )
E('(.*)c(.*)'                 , 'abcde'                     ,  0,  3 )
E('abcd'                      , 'abcd'                      ,  0,  4 )
E('a(bc)d'                    , 'abcd'                      ,  0,  4 )

E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Muammar Qaddafi"           ,  0, 15 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Mo'ammar Gadhafi"          ,  0, 16 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Muammar Kaddafi"           ,  0, 15 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Muammar Qadhafi"           ,  0, 15 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Muammar Gadafi"            ,  0, 14 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Mu'ammar Qadafi"           ,  0, 15 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Moamar Gaddafi"            ,  0, 14 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Mu'ammar Qadhdhafi"        ,  0, 18 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Muammar Khaddafi"          ,  0, 16 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Muammar Ghaddafy"          ,  0, 16 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Muammar Ghadafi"           ,  0, 15 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Muammar Ghaddafi"          ,  0, 16 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Muamar Kaddafi"            ,  0, 14 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Muammar Quathafi"          ,  0, 16 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Muammar Gheddafi"          ,  0, 16 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Moammar Khadafy"           ,  0, 15 )
E("M[ou]'?amm*[ae]r .*([AEae]l[- ])?"..
  "[GKQ]h?[aeu][aeu]*([dtz][dhz]?)([dtz][dhz]?)*af[iy]",
  "Moammar Qudhafi"           ,  0, 15 )

E('aa*(b|c)*dd*'                  , 'aabcdd'                ,  0,  5 )
E('..*'                           , 'vivi'                  ,  0,  1 )
E('..*'                           , ''                      ,nil,nil )
E('(..*)'                         , 'vivi'                  ,  0,  1 )
E('([^!%.][^!%.]*).att.com!(..*)' , 'gryphon.att.com!eby'   ,  0, 17 )
E('([^!][^!]*!)?([^!][^!]*)$'     , 'bas$'                  ,  0,  4 )
E('([^!][^!]*!)?([^!][^!]*)$'     , 'bar!bas$'              ,  0,  8 )
E('([^!][^!]*!)?([^!][^!]*)$'     , 'foo!bas$'              ,  0,  8 )
E('([^!][^!]*!)?([^!][^!]*)$'     , 'foo!bar!bas$'          ,  4, 12 )
E('..*!([^!][^!]*!)?([^!][^!]*)$' , 'foo!bar!bas$'          ,  0, 12 )
E('((foo)|(bar))!bas'             , 'bar!bas'               ,  0,  7 )
E('((foo)|(bar))!bas'             , 'foo!bar!bas'           ,  4, 11 )
E('((foo)|(bar))!bas'             , 'foo!bas'               ,  0,  7 )

E('([^!][^!]*!)?[^!][^!]*$|..*![^!][^!]*![^!][^!]*$' , 'foo!bar!bas$' , 0,12 )
E('([^!][^!]*!)?[^!][^!]*$|..*![^!][^!]*![^!][^!]*$' , 'bas$'         , 0, 4 )
E('([^!][^!]*!)?[^!][^!]*$|..*![^!][^!]*![^!][^!]*$' , 'bar!bas$'     , 0, 8 )
E('([^!][^!]*!)?[^!][^!]*$|..*![^!][^!]*![^!][^!]*$' , 'foo!bar!bas$' , 0,12 )
E('([^!][^!]*!)?[^!][^!]*$|..*![^!][^!]*![^!][^!]*$' , 'foo!bas$'     , 0, 8 )

E('.*(/XXX).*'                    , '/XXX'                  ,  0,  4 )
E('.*(\\XXX).*'                   , '\\XXX'                 ,  0,  4 )
E('\\XXX'                         , '\\XXX'                 ,  0,  4 )
E('.*(/000).*'                    , '/000'                  ,  0,  4 )
E('.*(\\000).*'                   , '\\000'                 ,  0,  4 )
E('\\000'                         , '\\000'                 ,  0,  4 )

E('.*(%/XXX).*'                   , '/XXX'                  ,  0,  4 )
E('.*(%%XXX).*'                   , '%XXX'                  ,  0,  4 )
E('%%XXX'                         , '%XXX'                  ,  0,  4 )
E('.*(%/000).*'                   , '/000'                  ,  0,  4 )
E('.*(%%000).*'                   , '%000'                  ,  0,  4 )
E('%%000'                         , '%000'                  ,  0,  4 )

--]]
