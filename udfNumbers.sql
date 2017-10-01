IF OBJECT_ID('udfNumbers') IS NOT NULL
	DROP FUNCTION udfNumbers
GO
-- function returns a table of numbers between the low and high
-- AUTHOR: Michael Allen Smith 
-- REPO: https://github.com/digitalcolony/sql-server-outer-join-date-range
CREATE FUNCTION udfNumbers (
	@lowNumber	INT,
	@highNumber	INT
)
RETURNS @NumberTable	TABLE (
	number INT
)
AS
BEGIN
	DECLARE @lenHigh	AS TINYINT
	-- Declare table with digits 0-9
	DECLARE @digits TABLE (digit TINYINT)
	INSERT INTO @digits
		(digit)
											SELECT 0
	UNION
		SELECT 1
	UNION
		SELECT 2
	UNION
		SELECT 3
	UNION
		SELECT 4
	UNION
		SELECT 5
	UNION
		SELECT 6
	UNION
		SELECT 7
	UNION
		SELECT 8
	UNION
		SELECT 9

	SET @lenHigh = LEN(@highNumber)

	IF @lenHigh = 1
		INSERT INTO @NumberTable
	SELECT digit
	FROM @digits
	WHERE digit 
			BETWEEN @lowNumber AND @highNumber
	ORDER BY digit

	IF @lenHigh = 2
		INSERT INTO @NumberTable
	SELECT 10 * Tens.digit + Ones.digit
	FROM @digits Ones CROSS JOIN @digits Tens
	WHERE 10 * Tens.digit + Ones.digit 
			BETWEEN @lowNumber AND @highNumber
	ORDER BY 10 * Tens.digit + Ones.digit

	IF @lenHigh = 3
		INSERT INTO @NumberTable
	SELECT 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit
	FROM @digits Ones CROSS JOIN @digits Tens CROSS JOIN @digits Hundreds
	WHERE 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit 
			BETWEEN @lowNumber AND @highNumber
	ORDER BY 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit

	IF @lenHigh = 4
		INSERT INTO @NumberTable
	SELECT 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit
	FROM @digits Ones CROSS JOIN @digits Tens CROSS JOIN @digits Hundreds CROSS JOIN @digits Thousands
	WHERE 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit 
			BETWEEN @lowNumber AND @highNumber
	ORDER BY 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit

	IF @lenHigh = 5
		INSERT INTO @NumberTable
	SELECT 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit
	FROM @digits Ones CROSS JOIN @digits Tens CROSS JOIN @digits Hundreds CROSS JOIN @digits Thousands CROSS JOIN @digits TenThousands
	WHERE 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit 
			BETWEEN @lowNumber AND @highNumber
	ORDER BY 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit

	IF @lenHigh = 6
		INSERT INTO @NumberTable
	SELECT 100000 * HundredThousands.digit + 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit
	FROM @digits Ones CROSS JOIN @digits Tens CROSS JOIN @digits Hundreds 
				CROSS JOIN @digits Thousands CROSS JOIN @digits TenThousands CROSS JOIN @digits HundredThousands
	WHERE 100000 * HundredThousands.digit + 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit 
			BETWEEN @lowNumber AND @highNumber
	ORDER BY 100000 * HundredThousands.digit + 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit


	RETURN
END
