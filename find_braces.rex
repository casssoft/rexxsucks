testcase1 = "(+ 1 2) )"
testcase2 = "(+ (+ 1 2) (+ 5 6)) 3)"
testcase3 = "(+ 1 (+ 5 6)) 5) 7)"
testcase4 = "() (5 )) ("
testcase5 = "+ 1 2) )"
testcase6 = "(+ 1 2"

/* Tests for test */
SAY "Testing CALL test 5, 3 should fail"
CALL test 5, 3
CALL test 5, 5
SAY "Testing CALL test 'hello', 'heLLO' should fail"
CALL test "hello", "heLLO"

/* Tests for countSymbol */
CALL test countSymbol("())", "("), 1
CALL test countSymbol("())", ")"), 2
CALL test countSymbol("))", "("), 0
CALL test countSymbol("((", ")"), 0
CALL test countSymbol("(abc)123)", "("), 1
CALL test countSymbol("(abc)123)", ")"), 2

/* Tests for findEndOfExpr */
CALL test findEndOfExpr(testcase1, 1), 3
CALL test findEndOfExpr(testcase2, 1), 7
CALL test findEndOfExpr(testcase3, 1), 5
CALL test findEndOfExpr(testcase4, 1), 1
CALL test findEndOfExpr(testcase5, 1), -1 
CALL test findEndOfExpr(testcase6, 1), 0 

RETURN

/* Function that returns 0 if its two inputs are equal, or -1 if they are
 * different.
 * test : left * right -> number
 */
test: PROCEDURE
  PARSE ARG left, right
  IF (compare(left, right) <> 0) THEN
    DO
      SAY "Test failed," left "<>" right
      RETURN -1
    END
  ELSE
    RETURN 0

/* Function that returns the number of times a specified symbol appears in a
 * word.
 * countSymbol : word * symbol -> count
 */
countSymbol: PROCEDURE
  PARSE ARG word, symbol
  length = wordLength(word, 1)
  charIndex = 1
  count = 0
  
  DO WHILE (charIndex <= length)
    char = subStr(word, charIndex, 1)
    IF (verify(char, symbol, 'M', 1) == 1) THEN
      count += 1
    charIndex += 1
  END

  RETURN count

/* Function that takes an expression enclosed in braces as an input argument
 * as well as an index into that string to a word that includes a left open
 * parenthesis. The function then finds the matching right parenthesis and
 * returns its word index to the caller. If no matching right parenthesis is
 * found in the inputString then 0 is returned. If the first word in the input
 * string does not have a left parenthesis then a -1 is returned.
 * findEndOfExpr : inputString * wordIndex -> wordIndex
 */
findEndOfExpr: PROCEDURE
  PARSE ARG inputString, startIndex

  /* Check to see IF the first word contains a left parenthesis. */
  IF (abbrev(inputString, '(', 1) <> 1) THEN
    RETURN -1

  wordCount = words(inputString)
  wordIndex = startIndex
  matched = 0

  /* Loop until the matching close brace is found. */
  DO WHILE (wordIndex <= wordCount)
    word = word(inputString, wordIndex)

    matched += countSymbol(word, "(")
    matched -= countSymbol(word, ")")

    IF (matched <= 0) THEN
      RETURN wordIndex

    wordIndex += 1
  END

  RETURN 0
