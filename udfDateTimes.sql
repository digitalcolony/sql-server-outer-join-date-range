IF OBJECT_ID('udfDateTimes') IS NOT NULL
	DROP FUNCTION udfDateTimes
GO
-- function returns datetimes between the start and end date
-- broken down by the time increment
-- AUTHOR: Michael Allen Smith 
-- REPO: https://github.com/digitalcolony/sql-server-outer-join-date-range
CREATE FUNCTION udfDateTimes (
	@startDate	DATETIME,
	@endDate	DATETIME,
	@interval	INT=1,  -- this is the interval per daypart default is 1
	@daypart	VARCHAR(10)
)
RETURNS @DateTimeTable	TABLE (
	dtime DATETIME
)
AS 
BEGIN
	DECLARE @lenDiff	TINYINT
	DECLARE @dateDiff	INT

	SELECT @dateDiff = CASE @daypart
		WHEN 'year' 	THEN DATEDIFF(yy,@startDate,@endDate)
		WHEN 'quarter'	THEN DATEDIFF(qq,@startDate,@endDate)
		WHEN 'month'	THEN DATEDIFF(mm,@startDate,@endDate)
		WHEN 'week'		THEN DATEDIFF(ww,@startDate,@endDate)
		WHEN 'day'		THEN DATEDIFF(dd,@startDate,@endDate)
		WHEN 'hour'		THEN DATEDIFF(hh,@startDate,@endDate)
		WHEN 'minute'	THEN DATEDIFF(mi,@startDate,@endDate) END

	SET @lenDiff = LEN(@dateDiff)

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

	IF @lenDiff < 3 
		INSERT INTO @DateTimeTable
	SELECT CASE @daypart
			WHEN 'year' 	THEN DATEADD(yy,10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'quarter'	THEN DATEADD(qq,10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'month'	THEN DATEADD(mm,10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'week'		THEN DATEADD(ww,10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'day'		THEN DATEADD(dd,10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'hour'		THEN DATEADD(hh,10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'minute'	THEN DATEADD(mi,10 * Tens.digit + Ones.digit,@startDate) END AS dtime
	FROM @digits Tens CROSS JOIN @digits Ones
	WHERE CASE @daypart
			WHEN 'year' 	THEN DATEADD(yy,10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'quarter'	THEN DATEADD(qq,10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'month'	THEN DATEADD(mm,10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'week'		THEN DATEADD(ww,10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'day'		THEN DATEADD(dd,10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'hour'		THEN DATEADD(hh,10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'minute'	THEN DATEADD(mi,10 * Tens.digit + Ones.digit,@startDate) END 
				BETWEEN @startDate AND @endDate
		AND (10 * Tens.digit + Ones.digit)%@interval = 0
	ORDER BY 10 * Tens.digit + Ones.digit

	IF @lenDiff = 3
		INSERT INTO @DateTimeTable
	SELECT CASE @daypart
			WHEN 'year' 	THEN DATEADD(yy,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'quarter'	THEN DATEADD(qq,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'month'	THEN DATEADD(mm,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'week'		THEN DATEADD(ww,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'day'		THEN DATEADD(dd,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'hour'		THEN DATEADD(hh,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'minute'	THEN DATEADD(mi,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate) END AS dtime
	FROM @digits Hundreds CROSS JOIN @digits Tens CROSS JOIN @digits Ones
	WHERE CASE @daypart
			WHEN 'year' 	THEN DATEADD(yy,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'quarter'	THEN DATEADD(qq,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'month'	THEN DATEADD(mm,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'week'		THEN DATEADD(ww,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'day'		THEN DATEADD(dd,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'hour'		THEN DATEADD(hh,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'minute'	THEN DATEADD(mi,100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate) END 
				BETWEEN @startDate AND @endDate
		AND (100 * Hundreds.digit + 10 * Tens.digit + Ones.digit)%@interval = 0
	ORDER BY 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit

	IF @lenDiff = 4
		INSERT INTO @DateTimeTable
	SELECT CASE @daypart
			WHEN 'year' 	THEN DATEADD(yy,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'quarter'	THEN DATEADD(qq,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'month'	THEN DATEADD(mm,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'week'		THEN DATEADD(ww,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'day'		THEN DATEADD(dd,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'hour'		THEN DATEADD(hh,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'minute'	THEN DATEADD(mi,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate) END AS dtime
	FROM @digits Thousands CROSS JOIN @digits Hundreds CROSS JOIN @digits Tens CROSS JOIN @digits Ones
	WHERE CASE @daypart
			WHEN 'year' 	THEN DATEADD(yy,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'quarter'	THEN DATEADD(qq,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'month'	THEN DATEADD(mm,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'week'		THEN DATEADD(ww,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'day'		THEN DATEADD(dd,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'hour'		THEN DATEADD(hh,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'minute'	THEN DATEADD(mi,1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate) END 
				BETWEEN @startDate AND @endDate
		AND (1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit)%@interval = 0
	ORDER BY 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit

	IF @lenDiff = 5
		INSERT INTO @DateTimeTable
	SELECT CASE @daypart
			WHEN 'year' 	THEN DATEADD(yy,10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'quarter'	THEN DATEADD(qq,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'month'	THEN DATEADD(mm,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'week'		THEN DATEADD(ww,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'day'		THEN DATEADD(dd,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'hour'		THEN DATEADD(hh,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'minute'	THEN DATEADD(mi,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate) END AS dtime
	FROM @digits TenThousands CROSS JOIN @digits Thousands CROSS JOIN @digits Hundreds CROSS JOIN @digits Tens CROSS JOIN @digits Ones
	WHERE CASE @daypart
			WHEN 'year' 	THEN DATEADD(yy,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'quarter'	THEN DATEADD(qq,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'month'	THEN DATEADD(mm,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'week'		THEN DATEADD(ww,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'day'		THEN DATEADD(dd,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'hour'		THEN DATEADD(hh,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'minute'	THEN DATEADD(mi,10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate) END 
				BETWEEN @startDate AND @endDate
		AND (10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit)%@interval = 0
	ORDER BY 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit

	IF @lenDiff = 6
		INSERT INTO @DateTimeTable
	SELECT CASE @daypart
			WHEN 'year' 	THEN DATEADD(yy,100000 * HundredThousands.digit + 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'quarter'	THEN DATEADD(qq,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'month'	THEN DATEADD(mm,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'week'		THEN DATEADD(ww,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'day'		THEN DATEADD(dd,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'hour'		THEN DATEADD(hh,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'minute'	THEN DATEADD(mi,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate) END AS dtime
	FROM @digits HundredThousands CROSS JOIN @digits TenThousands CROSS JOIN @digits Thousands CROSS JOIN @digits Hundreds CROSS JOIN @digits Tens CROSS JOIN @digits Ones
	WHERE CASE @daypart
			WHEN 'year' 	THEN DATEADD(yy,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'quarter'	THEN DATEADD(qq,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'month'	THEN DATEADD(mm,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'week'		THEN DATEADD(ww,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'day'		THEN DATEADD(dd,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'hour'		THEN DATEADD(hh,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'minute'	THEN DATEADD(mi,100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate) END 
				BETWEEN @startDate AND @endDate
		AND (100000 * HundredThousands.digit + 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit)%@interval = 0
	ORDER BY 100000 * HundredThousands.digit + 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit

	IF @lenDiff = 7
		INSERT INTO @DateTimeTable
	SELECT CASE @daypart
			WHEN 'year' 	THEN DATEADD(yy,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'quarter'	THEN DATEADD(qq,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'month'	THEN DATEADD(mm,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'week'		THEN DATEADD(ww,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'day'		THEN DATEADD(dd,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'hour'		THEN DATEADD(hh,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'minute'	THEN DATEADD(mi,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate) END AS dtime
	FROM @digits Millions CROSS JOIN @digits HundredThousands CROSS JOIN @digits TenThousands CROSS JOIN @digits Thousands CROSS JOIN @digits Hundreds CROSS JOIN @digits Tens CROSS JOIN @digits Ones
	WHERE CASE @daypart
			WHEN 'year' 	THEN DATEADD(yy,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'quarter'	THEN DATEADD(qq,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'month'	THEN DATEADD(mm,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'week'		THEN DATEADD(ww,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'day'		THEN DATEADD(dd,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'hour'		THEN DATEADD(hh,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate)
			WHEN 'minute'	THEN DATEADD(mi,1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit +1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit,@startDate) END 
				BETWEEN @startDate AND @endDate
		AND (1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit)%@interval = 0
	ORDER BY 1000000 * Millions.digit + 100000 * HundredThousands.digit + 10000 * TenThousands.digit + 1000 * Thousands.digit + 100 * Hundreds.digit + 10 * Tens.digit + Ones.digit

	RETURN
END
