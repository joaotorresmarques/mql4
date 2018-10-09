//+------------------------------------------------------------------+
//|                              Script:   P4L OrderHistory.mq4 (V9) |
//| Copyright © 2007-2014, Pips4life @ http://www.ForexFactory.com   |
//| Install this under C:\...\your_MT4\experts\scripts\              |
//+------------------------------------------------------------------+
#property show_inputs  // This key property for scripts brings up a popup window of the external variables.

#property copyright "Copyright © 2007-2014, Pips4life @ http://www.forexfactory.com"
#property link      "http://forexfactory.com/showthread.php?t=46668"
// 
// CRITICAL NOTE: 
// This script will display on a chart the closed and/or open trades that are 
// within the Custom Period range you choose in the Terminal->AccountHistory tab!
// In addition, you can export/import trade history data to combine history
// from multiple brokers.  Using >=V5, you can read an MT4 Statement into Excel,
// save it as a tab-delimited file and use that as an input file to this script.
//
// Many details are below, but bottom line: This script marks your history
// trades (open->close) and/or still-open trades on a chart using Arrows, 
// Text, and Trendlines.  You can study your trade history to improve
// your skills.   You can also output the trade history and import the 
// (tab-delimited) .csv file into Excel for further analysis.

// There is a useful "Instructions for use" section after the Version History below.

/* Version History:
NOTE TO PROGRAMMER: With any version update, also update "_INFO_Version_V#" further below.
2014-JUL-04, V9 of script "P4L OrderHistory.mq4" (by pips4life):
  Minor updates due to new MQL45 (MT4 build>=600)
  
2013-Jan-23, V8 of script "P4L OrderHistory.mq4" (by pips4life): 
(Fyi, v8 was never uploaded to FF as there were very minor changes)

  NEXT: (Done. Untested). Add stringToLC when looking for "buy", "sell" etc. strings just in case the user's
    file is wrong.
    
  NEXT: Review my code change that added "firstReadString".  MT4 had a bug detecting the
    end-of-file.   It seems to work but only tested with a 1-data-line file.
    
  NEXT: Review the thread for ideas/suggestions.
  
  NEXT: Need to enhance the "SECRET"=true to suppress the accountNumber.  Also might want
    to suppress the "Comments" but I'm not sure it's needed.   Similarly, might want to change
    the Order# to a made-up sequential counter (much like trades by the EA simulator does).
  
  NEXT: FF "Hanky" suggested a live indicator/EA version that would plot live trades taken
    by EA(s).  If restricted to "Open" trades it might not overload CPU.  The loop must
    store all live trades, process them, then next loop STILL USE the old "live trade" list
    PLUS a newly updated live-trade list.  That insures that recently closed trades get 
    one final update of objects.  Need to consider the object names used by the script vs.
    the object names used by this indicator.  Would want to be able to drag the script at
    any time, yet not have stale objects hang around.  The indicator should manipulate the
    same objects.
    
2011-Nov-04, V7 of script "P4L OrderHistory.mq4" (by pips4life):

  Fixed bug with Output columns that reported "pips".  The values were correct for the 
    current chart pair (say, a 4-digit pair like EURUSD), but would be off by x100 for
    other pairs (say, a 2-digit pair like USDJPY).  The Output file now contains a 
    column called "pip" which is the price of a standard pip (e.g. "0.0001" for EURUSD,
    regardless of whether it's from a 4-digit or 5-digit broker).   Changed the function
    "getPoint" to "getPointForSymbol".
  
  The StartDate and EndDate variables were renamed.  Created new variables "Start_Date_OR_Number_of_weeks" and 
     "End_Date_OR_Number_of_weeks".  The values now accept a simple integer value to specify
    the number-of-weeks prior to the current date&time.  Default Start_Date_OR_Number_of_weeks is "8".
    A value of "0" (or negative) is a shortcut to get ALL trade history.
    The user can still enter specific dates if desired.  (Fyi, 1970.01.01 is the earliest valid date).
    
  New variable "Make_Dollars_and_LotSize_SECRET" (false) can be set to True if the user wants
    to keep the Dollar amounts and LotSize secret.  Profitable trades simply show a profit 
    of "1.00", and unprofitable trades show "-1.00".  "Break-even" trades show a profit of
    either 0.01 or -0.01.  The LotSize is set to "1.0" for every trade.
    This affects all the created objects, AND it affects the values in the Output file.  The
    benefit of this option is to allow a user to share the Output file (or possibly a Template
    file with the objects) with another person that shows the trades taken but gives no private
    details with respect to the profit/loss or the size of the trades.  FYI, Swap and Commissions
    are also set to zero, since these indirectly indicate the LotSize.  (NOTE: The User must
    VERIFY the Output file content to insure that private details are not inadvertantly left 
    in the file! Especially check the Comments column. Open a blank Excel worksheet and import
    the Output file to inspect the details.)

  
  New variable "OUTPUT_SuppressBlankSymbolLines" (false) can be set to True if the user wants
    to suppress from the OUTPUT file all transactions which have a blank symbol name.  These 
    include account deposits, withdrawals, transfers, adjustments, commissions charged 
    after-the-trade, etc.  (FYI, this variable is auto-forced to True if Make_Dollars_and_LotSize_SECRET=True).

  FYI: Limitation:  ECN Broker MB Trading and perhaps others include only 1/2 the trade-commission charged on
    the actual trade record.  After the trade is closed, a new transaction is entered that adjusts
    the account balance by charging the other 1/2 commission after-the-fact.  These later commissions
    are NOT joined back with the original transaction when calculating the original trade profit, win/loss, 
    break-even status, etc.  While this could be fixed, the programming effort would be extensive.
    Commissions (and 1/2 commissions) are usually a fraction of a pip so it's just not worth the effort.
    
2011-May-18, V6 of script "P4L OrderHistory.mq4" (by pips4life):
  For original single orders that get split into 2-or-more orders by multiple closes,
    the original OrderOpenTime is now stored and used by the subsequent newly split orders,
    rather than the time when the order was split.  This OpenTime behavior changed, either
    within MT4 in early 2011 (maybe version >= 400), or it's a recent change by one or more
    brokers that includes "MB Trading".  When an order is split, the first order, say 1001, 
    has the comment "to #1002".  Order 1001 was closed with the 1st split, then a new 
    order 1002 was opened with the remaining #lots. The new problem with MB-Trading MT4 is 
    that the new OrderOpenTime is the time the order was split, NOT the time the 1st order
    was opened.  The random time with the original OpenPrice would put buy/sell arrows and
    lines out in space at non-sensical locations.  This version fixes that problem.  All split 
    orders have their arrows and trendlines start at the original (1st) OpenTime and OpenPrice.
    (FYI, MB Trading with version 402 has this problem.  Oanda with version 229 does NOT have
    this problem.  Therefore, either MT4 changed, or, it's broker specific.   FYI, if your 
    trade history doesn't have this problem, the fix won't hurt it, but you could disable the
    fix by setting variable "AutoFixOpenTimeForSplitOrders" = FALSE).

2010-Aug-23, V5 of script "P4L OrderHistory.mq4" (by pips4life):
  The input/output file format was changed but files created by previous versions ARE
    still compatible as input files.   The main change was to move the "account" 
    column(1st) to just after "demo", and to add a "taxes" column after "commission".
    The reason is to make the first columns the same values as a standard MT4
    transaction history report so that such reports can be converted into compatible
    data files for input and display.  (This is done by importing the HTML data into
    Excel, then saving the trade section to a tab (or comma) delimited file). 
    (Requested by FF user "Num")
  Added variables Input_File_Delimiter and OUTPUT_File_Delimiter.  Both have 
    defaults of "Tab", but "Comma" could be another logical choice.
  Added variable "DrawMostObjectsAsBackground" (True).  The normal use model also
    assumes that the Charts->Foreground is unchecked (false).  I doubt the use of
    "false" would be used much but it's there because there was mention of it by users.
  When specifying 1-or-more input files, these normally ADD to the trades in your
    AccountHistory.  Suppose you don't want to see any AccountHistory trades.  Though you 
    could change the custom date range to something which has zero trades taken, a new 
    easier way to avoid showing AccountHistory trades is to specify the input file(s)
    with the initial keyword-and-space "ONLY " (e.g. "ONLY mytrades.csv").
    As an alternative to using the keyword "ONLY ", the user can change variable
    "IncludeTradesFromAccountHistory" to "false", which has the same effect (and only works
    when input file(s) have been specified).
    
  There is a private-author's section to import a library file that defines a non-public 
    routine called "convertStratTesterFormatToInput" which as the name implies, will plot
    the trades taken by any EA that is tested using the MT4 StrategyTester.  This routine
    has not been provided or posted for free/public use by the author, pips4life.
  
2010-Jan-11, V4 of script "P4L OrderHistory.mq4" (by pips4life):
  (Sorry for the quick V4 change!  Figured out "Open" orders!)
  Support for Open trades was added.  opentime-Arrows, Text, Trendlines
    displayed but NOT closetime-Arrows.  ClosePrice and CloseTime are
    assumed to be current market price and time.
    The profit (net or gross) is simply displayed as "OPEN:$ xx.xx"
    Variable: Show_ClosedOpenAll_Trades_123 does:
       1: Closed trades only
       2: Open trades only    (but NOT "Open" trades read from input files)
       3: Closed AND Open trades
 If Open trades are "Shown" (above) AND if an Output file was entered, then the
    outfile contains THIS MT4's open trades (for Excel analysis) but open 
    trades read from any input file(s) are ignored (and discarded), because 
    they would be misleading.  Nothing is known about the status
    nor any accurate profit can be known because different brokers have
    different dollars-per-pip (e.g. $1 vs. $10), and for many pairs, the
    profit-per-pip is not an even $1 or $10 but a real-time calculation
    such as "$ 1.4392" one minute, and "$ 1.4385" the next.
  Fixed bug to detect when Output matches Input file, and exit if so.
  Added boolean "closed" and "demo" fields to the output/input database files.
  Four placeholder columns put in database format for future reassignment.
    Going forward, old data files *may* be compatible with newer script versions.
  The profit string for demo trades is prefixed with a "*" (e.g. "*Net:$ xx.xx")
  
2010-Jan-11, V3 of script "P4L OrderHistory.mq4" (by pips4life):
  (Used to be called "OrderHistory V2.mq4" and before that, "OrderHistory.mq4")
  
  MANY GREAT NEW FEATURES ADDED!
  
  Renamed to "P4L OrderHistory.mq4" to match other programs I've written/enhanced.
  
  When added to a chart, the script now shows a popup to change input variables.
  
  Data can now be written to a .csv output filename (tab delimited).   If desired,
    lot sizes can be scaled (if not "1", then usually by "0.10" or by "10").
    Open, Close, and Expiration times can be shifted by #-of-hours (+/-). (The
    shift is a double variable so "0.5" for a 30minute shift is supported also).
    Filename is specified with variable: OUTPUT_HistoryTo_FileName_CSV
    If the name contains no "." (period), then ".csv" is automatically appended.
    WARNING!! An output file will OVERWRITE any existing file unless you
    specify the name as "append filename"
  Data can also be read from one-or-more .csv input filenames (tab delimited).
    As with outputs, input lot sizes can be scaled, and times can be shifted.
    The filename(s) are specified with variable: Input_HistoryFrom_FileNames_CSV
    Either the exact name must match, or the name+".csv" must match.
    ANOTHER method to input filename(s) is to create a Label (or Text) with
    the object named "InputFiles" (case-sensitive!) and the 
    Description = "...filename(s)".  A manual entry of a filename overrules 
    the object.  (Popup Alerts give all the details, so please read them).
  The benefits of the ability to output and input files include:
    Transfer trade information easily into Excel for further analysis.
      (Open a blank worksheet, Data->Import External Data->Import Data, specify
       path to filename, check "Delimited", specify "Tab" delimiter, ...)
    Combine trades from different brokers and display the trades
    on one MT4. (**NOTE: The timeshifts must align. If your brokers follow the
    same ST/DST changeover dates, this is straightforward but if they don't, 
    you'll likely have to select various date ranges of data and output them
    with unique timeshift values for each group, and then combine together.
  NOTE: All filenames should be in the folder C:\...\_your_MT4\experts\files\
  
  To stay within the MT4 62-character Description limit, some syntax was shortened:
    Examples: "Pips: 10" is now "10p".   "Lots: 0.50" is now "#0.5"
  If SL=0, it is suppressed from the output.  Same with TP=0
  DisplayTexts=false by default (because it's too cluttered). User can change it if desired.
  Texts now include #lots.
  New "ShowTimeString" variable (true) to display how long the trade lasted from open->close.
    2nd variable "TimeIncludesSeconds" (false) controls the syntax.  If false, the appended 
    string is ", HH:MM", or if > 24 hours, ", D_HH:MM". If true, ":SS" is added.
    NOTE: By default, ":SS" is not included because that's 3 more characters which is
    closer to the 62-character Description limit.
  ArrowSize_1to5 default is now 3 (bigger than the previous choice of 1).  It is easily changed
    by an external variable.
  New "DeleteCreatedObjects" variable. When finished, add script to chart again but
    set this variable to True to clean up the objects off of the chart.  Another change is 
    that all added objects are deleted at the start of the script so it is now much easier
    to change the history Custom Period to both delete old objects and then display a new
    set of objects for a different period.
  External color variables are defined for ease of changing.  Some colors were changed
    to be more-or-less compatible with either Black or White background charts.  (The previous
    set was only for Black background).
  New variables FontName and FontSize for ease of customizing the Text object style.
  New variable "AutoPipTenthsFor5DigitBroker" (true) is intended to divide broker-pips by 10
    to get true pips.  On an extra-digit broker, a reported "10 pips" is actually 
    just 1 pip, so, with this variable "true", the 1/10th adjustment is made automatically.
    There is no impact on normal 2/4 digit brokers. (Example 4 vs. 5 price: 1.3452 vs. 1.34523)
  Tenths of pips are supported and displayed (if non-zero), regardless of extra-digit broker or not.
    This was done to allow the user to combine data from different brokers, some of which may be
    extra-digit brokers, and to display the trades on a 2/4 digit broker without loss of details.
  New "BrkEvenTolerance_DollarsPerLot" variable, "1.0" by default.  A break even Arrow is used if
    the NetOrGrossProfit is within +/- tolerance. 0 is no tolerance. "1" is +/- $1/lot tolerance. 
    This is useful for a broker that charges a commission. If you close your trade at entry+1pip 
    (to cover the commission), it is unlikely to be exactly "0" NetOrGrossProfit.  This variable
    gives a slight tolerance, and if within the tolerance, a B.E. Arrow is used instead of the
    Profit (or Loss) Arrow.  (Note: The formula used is +/-, but could have instead been if
    profit was between 0 and a +tolerance.  The looser +/- definition was preferred, but the
    tighter definition can be uncommented in 2 places; search below for "tighter" to find them).
  Slippage calculations are done.  Not all slippage can be detected, but two categories can be.
    SLslip: If a Buy trade closed below the S/L, the difference is slippage (a greater loss).
    TPadd: If a Buy trade closed above the T/P, the difference is positive-slippage (more profit).
    Similar calculations are made for Sell trades.  A new external variable was defined:
    "SlippageToleranceWithin_Pips" (default 1.0) will ignore slippage if <= tolerance.
    Any SLslip above the tolerance is reported with the string "slip #pips" (e.g. "slip -3.4").
    And TPadd above the tolerance is reported with the string "add:#pips") (e.g. "add:3.4")
  Suppress T/P and S/L arrows when they are coincident with the close price, UNLESS there was
    slippage!  Values for SLslip or TPadd(positive-slippage) are calculated.  If greater than
    the tolerance, the arrows are displayed at the close.  FYI, one can search the list of 
    objects to look for names starting with: _B_SLS  _B_TPA  _S_SLS  _S_TPA
    TIP: Tools->Objects->Object List, or Control-B brings up the object list. If you select 
    a line and click "Show", the chart will shift back in history to display the object (Note,
    first turn off "Auto Scroll").  One can also check the box to select/deselect the object 
    to make it easier to find on the chart.
  To show any trades, the user must adjust the Period in the Navigator->AccountHistory tab.
    However, if the range is too tight, a new Alert message tells the user there were no
    trades within the range, and reminds the user to choose a Custom Period.
  New Start_Date_OR_Number_of_weeks and End_Date_OR_Number_of_weeks variables were added.  Syntax: YYYY.MM.DD [HH[:MM[:SS]]]  
    On one MT4 broker, this is of limited use because the user can already control the 
    date range with a Custom Period.  There is only a slight benefit with the ability to 
    more specifically limit trades by HH:MM:SS.  However, when importing trades from another 
    MT4 broker, these Start_Date_OR_Number_of_weeks and End_Date_OR_Number_of_weeks variables are an easy way to isolate the desired 
    trades by date.  
  Variable "RequireCloseWithinDateRange" when "false" will consider only the OpenTime
    of the trade.  Any Arrow, Text, or Line within the range will display.
    When "true", both OpenTime and CloseTime must occur within the date-range.  The
    looser definition (false) was preferred for the default.
    (FYI, "Expiration" time is presently ignored because... what is it??? I don't know.)
  Some object Background properties were controlled to aid visibility of objects and/or bars.
    The display isn't perfect but at least now it's controlled for consistency.
  Object names now start with "_" to group them and be excluded by other indicators, and to
    allow them to be easily deleted/refreshed each time the script is added to the chart.
  Several "Print" statements of errors were changed to "Alert" to give a popup message.
  Many new Alert messages were added to aid the user when problems occur.
  
  
  INFORMATION: For full disclosure, MT4 has some limited built-in capabilities to display
  trade information on a chart. If you mouse click-and-drag a trade from the AccountHistory
  tab onto a chart, it will both change the chart to that trade symbol, and mark the trade on 
  the chart with limited information about THAT ONE trade.   If you want to mark ALL trades  
  for any given symbol on a chart, hold the "Shift" key down when you click-and-drag a trade 
  (for the desired symbol) onto the chart.  The Arrows it adds are not especially good choices
  and there are no extremely useful trendlines that mark the trade from open-close.  Hence,
  this script is far more capable than what MT4 provides.
  
  
2007-Sep-12 V2 Enhancements (Pips4life):

* Most sections rewritten.  However, as I am a hacker, not a programmer (back in Sep 2007), the 
code may not be the best or most elegant.  Seems to work pretty well though.

* Added lines to graphically show the duration of the trade, at 
entry and exit.  The color and line style indicate whether it was a Buy or 
Sell, and whether it was positive or negative profit.

* V1 had bugs with confusing OrderProfit and OrderTakeProfit.  Placement of 
some arrows made no sense before.  Text placement was more crowded. Fixed.

* Cancelled orders are distinguished from opened/closed orders.

* Swap and Commission are now considered when deciding if a trade has a net profit.
(Note: I don't pay Commissions with my broker, only the usual Spread.  My assumption 
is Commission entries are negative numbers (charges).  If they
are positive numbers in the database, the calculation must be changed.)
(UPDATE: The calculations are correct).

2006-Jan-21 Arunas Pranckevicius(T-1000), Lithuania, irc://irc.omnitel.net/forex:
   Original (V1) came from: http://codebase.mql4.com/318


//------------------------------------------
Instructions for use:
1. Copy this script to the location:
C:\Program Files\<your MT4 name here>\experts\scripts\   (Note: NOT under "indicators" !!)

2. Exit & restart MT4 to auto-compile the script and make it available to you
in the MT4 Navigator window under "Scripts".   
(Restarting MT4 is the easiest and surest way, but just doing a "Compile" of the script 
in MetaEditor usually works too).
3. Open a new blank chart that you have done historical trades on. 
4. Open the MT4 Terminal window  (Control-T will do it).
5. Select the "Account History" tab. 
6. Just ABOVE (not ON!) the "Account History" tab, Right-mouse-click.  The top line of
the menu should say "All History", and there should also be the choice "Custom Period".
Change as desired to a date range that definitely displays one-or-more trades.  (If 
there are no trades for this chart, the script will have nothing to display).
7. From the Navigator window (Common tab), left-click to expand "Scripts"
8. Drag-and-drop this script onto the chart. In the popup, customize variable settings as desired.
9. Change the chart timeframe as desired to see detailed points of entry. The M1 or M5 
     charts are usually much easier to read, especially for scalping (short) trades.  

10. Optional:  If you prefer different external variable defaults, then open MetaEditor and edit 
the script's defaults or colors, then "Compile" it.
11. Optional:  The normal use model assumes that the F8 property of Charts->Foreground is OFF. The 
arrows and objects mostly tend to draw on top of price bars, but there is some control over Background
properties and the user can experiment with settings.
12. Private author feature: Run StrategyTester with any EA, use "Copy All" to copy the trades and paste
them into an empty Excel file. Save the Excel file as a tab-delimited file, and use it as an input file.
(It helps to specify "ONLY filename" to isolate the EA trades from your other AccountHistory trades).
A special (non-public) routine converts the format into a compatible input-file format and displays the
trades on a chart.  IF THE TRADELINES DO NOT match actual price bars, your EA simulation likely had a 
low-modeling quality that does not match reality.
  
Examples:
A. Try the script with normal defaults. Arrows and trendlines mark your trades.
B. Turn on/off the DisplayTexts option above.  Turning it on displays additional Texts.
C. Turn off both lines and text, and set the DisplayArrows=2
You will see only your entries but no exits nor (trade) trendlines.  You can then
step through bar-by-bar (use F12) to watch the price action, and guess 
whether those were good or bad entries and where you think you should have
exited or how you should have set S/L and T/P.  Then highlight the arrow to 
know how it actually played out, which will display Pips/SL/TP/#lots/profit.

//------------------------------------------
Future Enhancement Ideas / Bug Fixes:
(Anyone willing to implement any of these ideas may do so.  Post the updates
back on the forexfactory.com forum, BUT CHANGE THE NAME.  Append something, like
"_V3_1", for example).  The official latest version will always be kept in Post #1
of the thread: http://forexfactory.com/showthread.php?t=46668

* Some brokers append an "m" or "M" to the end of their symbol name, generally to
connotate that the contract size is a "mini-lot".  If one uses an input or output file 
for such a broker, the symbol names might need to either add or strip off the "m".
The code could probably detect this automatically and make the name conversion.

* Open another window to track running relative profit/loss (a running subtotal).
In the same window, or perhaps another window, there could be a bar for absolute
profit/loss for any trade closed right above it.  Perhaps a histogram and/or a line.

* Statistics could be displayed on the chart.  Biggest loss/gain, consecutive
losses/gains, drawdown, peak profit, etc.

* Flag the peak profit that had been obtained between open and close.  Especially
helpful if you ended up taking a loss instead of once-obtained-profit.

* Flag the peak S/L that occurred between open and close.  Study whether your
normal S/L was too big compared to the typical peak S/L necessary to still be
in the trade and close (as you did).

* Consider hypothetical adjustment of stop-loss, making it larger.  Find the peak
high (for buy) or low (for sell) that occurred after that without hitting the S/L.
Similarly, ignore the T/P and make the same calculation.

Peak after T/P can already be determined for orders that hit T/P with the current S/L.

* One user requested a feature to track how a trade might have gone some specified
time after it's close.  

* Consider making this an indicator rather than a script if there are advantages (??).

* Personally, I'm not totally satisfied with the placement of texts although it is
improved.  Consider using the current timeframe's iATR instead of 60 minutes only.
Consider detecting whether the newest text object is on top of previous text. 
(Compare Price and possibly time).  If texts could be Left Justified, that would
be helpful.  The current Center Justification makes it harder to line up which
text goes with which arrow. (Or even Right Justification could be better??).
Possibly create a counter of 3-4 offsets.  Rotate which offset is used.  That way
if an order is split (closed at different times/prices) the labels would offset
so long as they are adjacent in the history database. (They likely are).

* Need a way to help identify multiple orders with the SAME entry price/time/exit,
especially S/L exits.  The problem is the Arrows and Lines are right on top of
each other.  The total trade may not be obvious if one highlights a single object.
The current charts may well show the quality of entries and exits but not well the 
quantity (lot sizes and if there were multiple positions).  Maybe a histogram of profit
can stack each profit or loss so one can see there were multiple orders instead
of just one.  At present, there will be multiple offset texts, but the arrows 
and lines will be on top of each other.

* Consider adjusting the arrow size based on Lot size.  Bigger arrow for larger
Lot size.


*/
//Note: The convertStratTesterFormatToInput library routine has NOT been posted for free/public use by the author.
int licensekey1 = 0;
int licensekey2 = 0;
#import "P4L OrderHistory LIB.ex4"   // Private file by pips4life.  If it doesn't exist it is ignored but the feature to read StrategyTester output (from EA's) won't work without it.
int convertStratTesterFormatToInput(string sthandlename, string InputDelimiter, string tmpfile, int myOrderAccount, string DefaultInputSymbolName, int StratTestOrderTicketNum_Offset, int licensekey1, int licensekey2);
#import

//Here are common things the user may wish to customize and then re-compile:
//FYI: NEW in V3... these settings can be customized when the script is added to a chart

extern string _INFO_Version_V9              = "... released on 2014-JUL-04 by pips4life";
extern string _INFO_Suggestions             = "Use F8 to toggle: Show Object Descriptions";
extern string _INFO_In_Terminal_Window__    = "...set desired Period in Account_History tab";
extern string _INFO__WHEN_YOU_ARE_DONE__    = "...Rerun&Set DeleteCreatedObjects to True";
extern bool   DeleteCreatedObjects          = False; // Use True to erase all the objects created by this script
extern string _INFO_Date_syntax             = "#weeks(0=all), or YYYY.MM.DD [HH[:MM[:SS]]] (optional between square brackets)";
extern string Start_Date_OR_Number_of_weeks = "8"; //"8" is 8 weeks.  Previous default was 1970.01.01.  "0" (or negative number) means 1970.01.01 (ALL trades).
extern string End_Date_OR_Number_of_weeks   = ""; //blank is up to the present
extern bool   RequireCloseWithinDateRange   = false; // false=Any trade opened within the range is marked/output.  True=ONLY if Opened AND Closed within range.
extern int    Show_ClosedOpenAll_Trades_123 = 3; // 1=only-closed-trades, 2=only-open, 3=all-trades
extern string _INFO_DisplayArrows_values    = "0=none, 1=Buy/Sell/SL/TP, 2=Buy/Sell";
extern int    DisplayArrows        = 1; // 0 = Turns off the display of all arrows.
                                        // 1 = Displays arrows for Buy/Sell/SL/TP
                                        // 2 = Displays only limited Buy/Sell arrows. No TP/SL or closing arrows.
extern bool   DisplayLines     = true;  // Visually show fixed-length trendlines for all orders
extern bool   DisplayTexts     = false; // Although decent, these texts may get a little too crowded to read. 
                                        // Note: If DisplayArrows=0, then DisplayTexts is forced to false.
extern int    ArrowSize_1to5   = 3;     // 1 is smallest, 5 is largest
extern double ExpandTextFactor = 0.9;   // Closer together, use < 1.0.  Farther apart, use > 1.0.
extern bool   AutoFixOpenTimeForSplitOrders = true;

extern bool   SubtractCurrentSpreadForBuys = false; // Subtract spread from the Buy portion of all trades.
                                            // Affects placement of graphical Lines and Arrows only.
                                            // Since charts display Bid prices only, subtracting the spread
                                            // may better estimate at what price was Bid when a Buy occurred.
                                            // Note: On most brokers, the spread varies, so the amount
                                            // subtracted can be different even a couple seconds later.
                                            
extern bool   ConsiderTotalNetProfit = true; // Include Swap and Commission charges to decide if a trade was profitable
extern bool   ShowTimeString         = true; // The total order time is displayed as: HH:MM, or if > 24hrs, D_HH:MM
extern bool   TimeIncludesSeconds    = false; // WARNING. If True, it adds 3 characters. Complete texts must be <= 62 characters total!
extern bool   AutoPipTenthsFor5DigitBroker = true; // On extra digit brokers (that use 3 or 5 decimal prices vs. the 
                                                   // usual 2 or 4), reduce broker-pips by 10X and report 10ths of pips.
extern double BrkEvenTolerance_DollarsPerLot     = 1.0; // Use a B.E. Arrow if NetOrGrossProfit is <= tolerance. 0 is no tolerance, "1" is +/- 1 dollar.
extern double SlippageToleranceWithin_Pips       = 1.0; // Slippage is ignored if <= tolerance value. SLslip is negative (bad). TPadd is positive-slip (good!)

// Reasonable colors chosen for BLACK or WHITE background charts  (change as desired):
extern color  BuyArrow          = RoyalBlue;        // was Blue
extern color  SellArrow         = Red;
extern color  ProfitArrow       = Aqua;
extern color  LossArrow         = HotPink;
extern color  SLArrow           = OrangeRed;        // was Yellow
extern color  ProfitSellLine    = Orange;           // was Gold
extern color  LossBuyLine       = Orchid;
extern color  ProfitBuyLine     = MediumAquamarine; // was PaleTurquoise
extern color  LossSellLine      = Red;
extern color  CancelledBuyLine  = DarkGray;         // was White, obviously only for BLACK background.
extern color  CancelledSellLine = Gray;
extern color  TextColor         = OrangeRed;        // was Yellow, good on BLACK, bad on WHITE.

extern bool   DrawMostObjectsAsBackground    = true; // True is normal use model with Charts->Foreground OFF. 
extern string FontName = "Times New Roman";
extern int    FontSize                         = 10;
extern string _____________________________1   = "====================================";
extern string _INFO_FOR_INPUT_OR_OUTPUT_DATA   = "...below, enter filename(s) for input and/or output";
extern string _INFO_Lot_scaling_values         = "Typ:1, sometimes 0.1 or 10";
extern double Scale_Input_LotSizesBy_Factor    = 1;
extern double Shift_Input_TimesBy_Hours        = 0;    // Compare 2 broker times. The offset (in hours) is usually obvious. Type "double" allows for 0.5 (30min) increments.
extern string Input_File_Delimiter             = "Tab"; //Keywords: Tab, Comma, Semicolon, or use the literal character. Do NOT use space or ":" or "." or other chars. in the data itself. 
extern int    DefaultInputAccountNumber        = 0; // 0=assume your account number. If non-zero, it's only used if inputing data from an MT4 Statement or a StrategyTester report.
extern int    StratTestOrderTicketNum_Offset   = 0; // Ticket numbers output by StrategyTester start with "1". The offset is added if desired.
extern string DefaultInputSymbolName           = "NULL"; //Only used if input is from StrategyTester. Assumed to be same as current chart UNLESS specified otherwise.
extern bool   IncludeTradesFromAccountHistory  = true; // To eliminate AccountHistory trades, set to "false"; or use Custom Date range; or below use keyword "ONLY inputfile.csv"
extern string Input_HistoryFrom_FileNames_CSV  = "";   // FYI, say "ONLY filename" to eliminate AccountHistory trades. ALTERNATE INPUT METHOD: Create a Label object named "InputFiles" with Description = filename(s)
extern string _____________________________2   = "====================================";
extern bool   OUTPUT_DataFor_ALL_Symbols       = true; //true=all trades regardless of current chart symbol. False=current chart symbol only.
extern double Scale_OUTPUT_LotSizesBy_Factor   = 1;
extern double Shift_OUTPUT_TimesBy_Hours       = 0;
extern string OUTPUT_File_Delimiter            = "Tab"; //Tab or Comma
extern string _INFO_WARNING_Output_file__      = "...OVERWRITES unless 'append filename' specified";
extern string OUTPUT_HistoryTo_FileName_CSV    = "";
extern bool   OUTPUT_SuppressBlankSymbolLines  = false; //False outputs ALL transactions including deposits/transfers/adjustments/commissions/etc., all that have a blank-symbol name.
extern bool   Make_Dollars_and_LotSize_SECRET  = false; //Usually False. True will hide details about Dollars and LotSize for Objects AND Output

// Other than possibly arrow choices or line styles, the typical user of this 
// script should not need to customize anything below this line
// ============================================================================

bool obj_created = false;
datetime starttime;
datetime endtime;
datetime origOpenTime[][2]; //[i][0] is orderNumber, [i][1] is the replacement openTime

#include <stdlib.mqh>

//+------------------------------------------------------------------+
void SetArrow(string symbol, string ArrowName, string ArrowDescription, datetime ArrowTime, double Price, double ArrowCode, 
      color ArrowColor, bool LimitArrow, datetime OtherTime)
{
   int err;

   // Note, if ArrowName was already used, the object will be replaced by current arrow.
   if (ObjectFind(ArrowName) != -1) ObjectDelete(ArrowName);
   if (symbol != Symbol() || !DisplayArrows || (DisplayArrows == 2 && LimitArrow))  return; // Return after deleting existing arrow is deliberate.
   
   //If ArrowTime out of date range, then exit. 
   if ( ArrowTime < starttime || ArrowTime > endtime ) return; 
   if ( RequireCloseWithinDateRange && ( OtherTime < starttime || OtherTime > endtime)) return; // stricter date-range
   
   if(!ObjectCreate(ArrowName, OBJ_ARROW, 0, ArrowTime, Price))
    {
     err=GetLastError();
     Alert("ERROR: can't create Arrow! code #",err," ",ErrorDescription(err));
     return;
    }
   else
   { 
   ObjectSet(ArrowName, OBJPROP_ARROWCODE, ArrowCode);
   ObjectSet(ArrowName, OBJPROP_COLOR , ArrowColor);
   ObjectSet(ArrowName, OBJPROP_WIDTH  , ArrowSize_1to5);
   ObjectSet(ArrowName, OBJPROP_BACK  , DrawMostObjectsAsBackground);
   
   ObjectSetText(ArrowName, ArrowDescription, 8, "Arial", ArrowColor);
   ObjectsRedraw();
   obj_created = true;
   }
} // end of SetArrow


//+------------------------------------------------------------------+
void SetText(string symbol, string TextName, string TextDescription, datetime TextTime, double TextPrice, color c_TextColor, datetime OtherTime)
{
   int err;
   
   if (ObjectFind(TextName) != -1) ObjectDelete(TextName);
   if (symbol != Symbol() || !DisplayTexts || !DisplayArrows)  return; // Return after deleting existing text is deliberate. Also delete Text if NO arrows!
   //if (symbol != Symbol() || !DisplayTexts)  return; // To get Texts even when NO Arrows displayed, use this line instead of the prior line.
   
   //If TextTime out of date range, then exit. 
   if ( TextTime < starttime || TextTime > endtime ) return; 
   if ( RequireCloseWithinDateRange && ( OtherTime < starttime || OtherTime > endtime)) return; // stricter date-range
   
   
   if (!ObjectCreate(TextName, OBJ_TEXT, 0, TextTime, TextPrice))
   {
     err=GetLastError();
     Alert("ERROR: can't create Text! code #",err," ",ErrorDescription(err));
     return;
   }
   else
   {
   ObjectSetText(TextName,TextDescription,FontSize,FontName,c_TextColor);
   ObjectSet(TextName,OBJPROP_BACK,False);
   ObjectsRedraw();
   obj_created = true;
   }
} // end of SetText     

//+------------------------------------------------------------------+
void SetLine(string symbol, string ObjName, string LineDescription, datetime LineOpenTime, double LineOpenPrice, datetime LineCloseTime, 
             double LineClosePrice, color LineColor, int LineWidth, int LineStyle)
{             
   int err;
   
   if (ObjectFind(ObjName) != -1) ObjectDelete(ObjName);
   if (symbol != Symbol() || !DisplayLines)  return; // Return after deleting existing line is deliberate.
   
   //If OpenTime out of date range, then exit. 
   //  Note: ONLY OpenTime considered.  If an Open arrow occurs, personally I want to see the entire trade line, even if closing Arrows are missing.
   if ( LineOpenTime < starttime || LineOpenTime > endtime ) return; 
   if ( RequireCloseWithinDateRange && ( LineCloseTime < starttime || LineCloseTime > endtime)) return; // stricter date-range
   
   if(!ObjectCreate(ObjName, OBJ_TREND, 0, LineOpenTime, LineOpenPrice, LineCloseTime, LineClosePrice))
   {
     err=GetLastError();
     Alert("ERROR: can't create Line! code #",err," ",ErrorDescription(err));
     return;
   }
   else
   {
   ObjectSet(ObjName,OBJPROP_RAY,0);
   ObjectSet(ObjName,OBJPROP_COLOR,LineColor);
   if (LineStyle > 0) ObjectSet(ObjName,OBJPROP_WIDTH,1); // Dashed/Dotted LineStyle requires a width of "1". STYLE_SOLID
   else ObjectSet(ObjName,OBJPROP_WIDTH,LineWidth); 
   ObjectSet(ObjName,OBJPROP_STYLE,LineStyle);   
   if (LineOpenPrice==LineClosePrice) ObjectSet(ObjName,OBJPROP_BACK,False); //An open limit/stop order is hidden unless Back=False
   else ObjectSet(ObjName,OBJPROP_BACK,DrawMostObjectsAsBackground);
   ObjectSetText(ObjName,LineDescription,FontSize,FontName,LineColor);
   ObjectsRedraw();
   obj_created = true;
   }
} // end of SetLine
              
//+------------------------------------------------------------------+
//| script program start function  (it runs only once)               |
//+------------------------------------------------------------------+
int start()
{
  int i;
  
  // Start by removing previous objects.
  int obj_total, objType;
  string objName;
  obj_total = ObjectsTotal();
  for (i=obj_total-1; i>=0; i--) // NOTE! When deleting objects as below, must count DOWN in this loop!
  {
     objName = ObjectName(i);
     objType = ObjectType(objName);
     if  ( 
           ( objType == OBJ_ARROW &&
             (    StringFind(objName,"_B_",0) == 0 
               || StringFind(objName,"_BC_",0) == 0 
               || StringFind(objName,"_S_",0) == 0 
               || StringFind(objName,"_SC_",0) == 0
             ) 
           ) ||
           ( objType == OBJ_TREND &&
             (    StringFind(objName,"_C_",0) == 0 
               || StringFind(objName,"_P_",0) == 0 
               || StringFind(objName,"_N_",0) == 0 
             ) 
           ) ||
           ( objType == OBJ_TEXT &&
             (    StringFind(objName,"_Buy_",0) == 0
               || StringFind(objName,"_BySt_",0) == 0
               || StringFind(objName,"_BLmt_",0) == 0
               || StringFind(objName,"_Sell_",0) == 0
               || StringFind(objName,"_SlSt_",0) == 0
               || StringFind(objName,"_SLmt_",0) == 0
             ) 
           )
         )
     ObjectDelete(objName);
  }
  if (DeleteCreatedObjects) return(0); //All done so exit.
  // end of cleanup.
  
  
  // This old method partially worked but only if the same input files and/or history-period was identical
  //if (DeleteCreatedObjects)
  //{
  //   DisplayLines = false;
  //   DisplayArrows = 0;
  //   DisplayTexts = false;
  //   // PROBABLY should loop objects and delete objects by pattern matching because,
  //   //   what if the user narrows the history date range?  The old objects 
  //   //   outside of the range don't get deleted!
  //   // Do NOT "return(0)" here.  As an object would otherwise get created, it is only deleted instead.
  //}
  
  if (StringFind(Start_Date_OR_Number_of_weeks,".",0) < 0 && StringFind(Start_Date_OR_Number_of_weeks,":",0) < 0 
     && StrToInteger(Start_Date_OR_Number_of_weeks) > 0) starttime = MathMax(0,TimeCurrent() - StrToInteger(Start_Date_OR_Number_of_weeks)*604800); //#weeks * 7*24*60*60
  else if (StringTrimLeft(StringTrimRight(Start_Date_OR_Number_of_weeks)) == "0" || StrToInteger(Start_Date_OR_Number_of_weeks) < 0) starttime = 0;
  else starttime = MathMax(0,StrToTime(Start_Date_OR_Number_of_weeks));
  
  if (End_Date_OR_Number_of_weeks == "" || StringTrimLeft(StringTrimRight(End_Date_OR_Number_of_weeks)) == "0") endtime = TimeCurrent();
  else if (StringFind(End_Date_OR_Number_of_weeks,".",0) < 0 && StringFind(End_Date_OR_Number_of_weeks,":",0) < 0
     && StrToInteger(End_Date_OR_Number_of_weeks) > 0) endtime = MathMax(0,TimeCurrent() - StrToInteger(End_Date_OR_Number_of_weeks)*604800); //#weeks * 7*24*60*60;
  else endtime = MathMax(0,StrToTime(End_Date_OR_Number_of_weeks));
  
//---- 
// retrieving info from trade history
  int      hstTotal=OrdersHistoryTotal(); // These are ONLY (closed) history orders.
  int      openTotal=0;
  if (Show_ClosedOpenAll_Trades_123 == 2) hstTotal=0; // Ignore history orders
  if (Show_ClosedOpenAll_Trades_123 > 1) openTotal=OrdersTotal(); // These are ONLY live orders, no history orders.
  
  string   InputDelimiter;
  string   OUTPUTdelimiter;
  
  int      myOrderType; 
  string   myOrderTypeString;
  int      myOrderTicket; 
  datetime myOrderCloseTime;
  double   myOrderClosePrice;
  datetime myOrderOpenTime;
  datetime NetTime;
  string   myOrderSymbol;
  double   myOrderOpenPrice;
  double   myOrderProfit;
  double   myOrderSwap;
  double   myOrderTaxes=0.0;
  double   myOrderCommission;
  double   myOrderTakeProfit;
  double   myOrderStopLoss;
  double   myOrderLots;
  int      myOrderMagicNumber;
  datetime myOrderExpiration;
  string   myOrderComment;
  int      myOrderAccount;
  bool     myOrderClosed;
  bool     myOrderDemo;
  double   myOrderPoint = 0.0;
  double   PlaceTextAtPrice;
  string   OrderName;
  string   OrderDescription;
  string   TextDescription;
  string   ObjName;
  string   ProfitString;
  string   LotString;
  double   Spread = 0;
  double   NetProfit = 0;
  double   NetOrGrossProfit = 0;
  string   discard;
  
  int whandle = -1;
  int rhandle[] = { -1 };
  string rhandlename[] = { "NULL" };
  string rfiles[];
  bool checkedFirstInputLine = false;
  int inputFileFormat = 5; //5 for V5, 4 for V4, but these values are detected and set further below.
        
  
  double SLpips;
  double TPpips;
  double NETpips;
  string SLpipsStr, TPpipsStr, NETpipsStr, TPaddStr, SLslipStr;
  double SLslip;
  double TPadd;
  
  int d,h,m,s;
  string TimeStr = "";
  string TimeStrSec = "";
  string HourStr,MinStr,SecStr;
  
  if (DefaultInputAccountNumber == 0) DefaultInputAccountNumber = AccountNumber();
  
  double myPoint = MarketInfo(Symbol(),MODE_POINT);
  double pointdiv10 = myPoint/10; // Even on 2/4 brokers, if 3/5 data is imported, this is needed to display 10ths of pips.
  if (AutoPipTenthsFor5DigitBroker && getPointForSymbol(true,Symbol()) != myPoint)
  {
    myPoint = getPointForSymbol(true,Symbol());
  }
 
  // Decide a suitable offset for text and a delta between multiple texts for readability.
  int TextOffsetBase = MathRound(ExpandTextFactor * iATR(NULL,60,20,0)/myPoint + 3);
  int TextOffsetDelta = MathRound(ExpandTextFactor * 0.20 * TextOffsetBase + 3);
  int TextOffsetCounter = 0;
  Print("FYI: 60/20 iATR is: ",iATR(NULL,60,20,0)," TextOffsetBase: ",TextOffsetBase,"  TextOffsetDelta: ",TextOffsetDelta);
  
  if (SubtractCurrentSpreadForBuys) 
  {
     RefreshRates( ); 
     Spread = Ask - Bid;
     // Note: This is valid for fixed-spread brokers, but not necessarily accurate
     // for brokers who change the spread a lot.  A non-typical spread at the moment this 
     // script is executed would be especially misleading.  However, it will only
     // affect where objects are drawn.  The reported price/TP/SL/etc numbers are
     // unaffected.
  }
  
  bool APPEND_FLAG=false;
  if (OUTPUT_HistoryTo_FileName_CSV != "")
  {
     if (StringFind(stringToUC(OUTPUT_HistoryTo_FileName_CSV),"APPEND ",0) == 0)
     {
        APPEND_FLAG=true;
        OUTPUT_HistoryTo_FileName_CSV = StringSubstr(OUTPUT_HistoryTo_FileName_CSV,7);
     }
  }
  
  int j=0;
  
  if (ObjectFind("InputFiles") >= 0)
  {
     if (Input_HistoryFrom_FileNames_CSV == "") 
     {
        Input_HistoryFrom_FileNames_CSV = ObjectDescription("InputFiles");
        Alert("Object InputFiles found with Filename(s)_CSV: ",Input_HistoryFrom_FileNames_CSV);
     }
     else Alert("FYI: The object InputFiles was ignored because you manually supplied filename(s)");
  }
  else if (Input_HistoryFrom_FileNames_CSV != "")
  {
     // Alerts are issued in REVERSE order for easier readability in the popup window.
     if (Shift_Input_TimesBy_Hours != 0 || Scale_Input_LotSizesBy_Factor != 1)
         Alert("... Create a new output file, scaled and/or shifted, then create a Label to read that new input file"); 
     if (Shift_Input_TimesBy_Hours != 0)     Alert("... HOWEVER, must still manually enter Shift_Input_TimesBy_Hours value!");
     if (Scale_Input_LotSizesBy_Factor != 1) Alert("... HOWEVER, must still manually enter Scale_Input_LotSizesBy_Factor value!");
     Alert("FYI: A persistent way to input files is to create a Label named InputFiles with Description=...filename(s)");
  }
  datetime infileTimeShiftSec = Shift_Input_TimesBy_Hours*3600;
  datetime outfileTimeShiftSec = Shift_OUTPUT_TimesBy_Hours*3600;
  
  if (OUTPUT_HistoryTo_FileName_CSV != "")
  {
     if (stringToUC(OUTPUT_File_Delimiter) == "TAB") OUTPUTdelimiter = "\t";
     else if (stringToUC(OUTPUT_File_Delimiter) == "COMMA") OUTPUTdelimiter = ",";
     else if (stringToUC(OUTPUT_File_Delimiter) == "SEMICOLON") OUTPUTdelimiter = ";";
     else OUTPUTdelimiter = OUTPUT_File_Delimiter;
     
     // First open the output file but do NOT yet write to it!  (It might match a read-file!)
     if (StringFind(OUTPUT_HistoryTo_FileName_CSV," ",0) >=0)
     {
        Alert("ERROR. No space allowed in OUTPUT_HistoryTo_FileName_CSV: '",OUTPUT_HistoryTo_FileName_CSV,"'");
        return(0);
     }
     
     if (StringFind(OUTPUT_HistoryTo_FileName_CSV,".",0) < 0) OUTPUT_HistoryTo_FileName_CSV = StringConcatenate(OUTPUT_HistoryTo_FileName_CSV,".csv");
     if (APPEND_FLAG) whandle=FileOpen(OUTPUT_HistoryTo_FileName_CSV,FILE_READ|FILE_WRITE|FILE_CSV,OUTPUTdelimiter);
     else whandle=FileOpen(OUTPUT_HistoryTo_FileName_CSV,FILE_WRITE|FILE_CSV,OUTPUTdelimiter);
     if(whandle<1) 
     {
        Alert("... Cannot write: ",TerminalPath(),"\\experts\files\\",OUTPUT_HistoryTo_FileName_CSV);
        Alert("Access to write-file failed with error (",GetLastError(),")");
        return(1);
     }
  }

  bool ONLYINPUTFILES_FLAG=false;
  if (Input_HistoryFrom_FileNames_CSV != "")
  {
     if (StringFind(stringToUC(Input_HistoryFrom_FileNames_CSV),"ONLY ",0) == 0)
     {
        ONLYINPUTFILES_FLAG=true;
        Input_HistoryFrom_FileNames_CSV = StringSubstr(Input_HistoryFrom_FileNames_CSV,5);
     }
     else if (!IncludeTradesFromAccountHistory) ONLYINPUTFILES_FLAG=true;
  }

  if (Input_HistoryFrom_FileNames_CSV != "")
  {
     if (stringToUC(Input_File_Delimiter) == "TAB") InputDelimiter = "\t";
     else if (stringToUC(Input_File_Delimiter) == "COMMA") InputDelimiter = ",";
     else if (stringToUC(Input_File_Delimiter) == "SEMICOLON") InputDelimiter = ";";
     else InputDelimiter = Input_File_Delimiter;
     
     stringSplitBySpaces(rfiles,Input_HistoryFrom_FileNames_CSV);
     for (int n=0; n<ArraySize(rfiles); n++)
     {
        rhandle[j]=FileOpen(rfiles[n],FILE_CSV|FILE_READ,InputDelimiter); // First try without appending ".csv" or ".txt"
        rhandlename[j]=rfiles[n];
        if(rhandle[j]<1)
        {
           rhandle[j]=FileOpen(StringConcatenate(rfiles[n],".csv"),FILE_CSV|FILE_READ,InputDelimiter); // Try again with ".csv" added.
           if(rhandle[j]>=0) rfiles[n] = StringConcatenate(rfiles[n],".csv");
           rhandlename[j]=rfiles[n];
        }
        if(rhandle[j]<1)
        {
           //rfiles[n] = StringConcatenate(rfiles[n],".txt");
           rhandle[j]=FileOpen(StringConcatenate(rfiles[n],".txt"),FILE_CSV|FILE_READ,InputDelimiter); // Try again with ".txt" added.
           if(rhandle[j]>=0) rfiles[n] = StringConcatenate(rfiles[n],".txt");
           rhandlename[j]=rfiles[n];
        }
        if(rhandle[j]<1) 
        {
           Alert("... Cannot read: ",TerminalPath(),"\\experts\files\\",rfiles[n]," (nor with .csv or .txt appended to name)");
           Alert("ERROR. Access to read-file, ",rfiles[n],", failed with error (",GetLastError(),")");
           //return(1);
        } 
        else 
        {
           j++;
           ArrayResize(rhandle,j+1);
           ArrayResize(rhandlename,j+1);
        }
        if (stringToUC(rfiles[n]) == stringToUC(OUTPUT_HistoryTo_FileName_CSV))  // Windows filenames are not case-sensitive.  abc same as ABC.
        {
           Alert("ERROR. Exiting because Output file matches Input file: ",rfiles[n]);
           return(1);
        }
     } //end of for
  } // end of if inputhistory_filenames
  j=0;
  

  if (OUTPUT_HistoryTo_FileName_CSV != "")
  {
     // Now we have the output open and know it does NOT match a read-file.
     // write header
     if (APPEND_FLAG) FileSeek(whandle,0,SEEK_END);
     else FileWrite(whandle,"order","opendt","type","lots","symbol","openprice","stoploss","takeprofit",
     "closedt","closeprice","commission","taxes","swap","profit", //up to here are the standard fields saved in an MT4 transaction report.
     "account","magicnumber","expirationdt","comment",
     "closed","demo","pip","x","x","x", // nothing after this field is *read* by this script. Any placeholder "x" columns are available for use!
     // What follows is for display purposes only and analysis in Excel:
     "action","net","pips","SLpips","TPpips","TimeStr","timesec","SLslip","TPadd",
     "opentime","closetime","expiration"); // These 3 times repeated in datetime format (seconds) for ease of Excel manipulation. They are NOT read in.
  }
  
  
  
  int k=0;
  
  // Below, i<=hstTotal is intentionally one too many, to cause an extra loop to read from the read-filename(s) (if any) and then to "break" from that
  for(i=0;i<=hstTotal;i++)  
  //for(i=0;i<hstTotal;i++)
  {
     if (!ONLYINPUTFILES_FLAG && (i<hstTotal || k<openTotal))
     {  
     
        if (i<hstTotal)
        {
           // This section is for true history trades
           //---- check selection result
           if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) // closed and cancelled orders.
           {
              Alert("Access to MT4 history records failed with error (",GetLastError(),")");
              break;
           }
           myOrderClosed=true;  //1(true)=closed, 0(false)=open
        }
        else //if (k<openTotal)
        { 
           // This section is to read still-OPEN trades from the MT4 database.  To suppress display, openTotal must be zero (it's 0 if Open trades not shown)
           if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES)==false) // opened and pending.  If closetime==0,open-or-pending based on type.
           {
              Alert("Access to MT4 open-trade records failed with error (",GetLastError(),")");
              break;
           }
           k++;
           i--; // to keep i-looping until a forced "break"
           myOrderClosed=false;  //1(true)=closed, 0(false)=open
        }
        
        
        myOrderSymbol = OrderSymbol();
        if (OUTPUT_HistoryTo_FileName_CSV != "" || stringToUC(myOrderSymbol) == stringToUC(Symbol()) )
        { // Get the details if outputing to a CSV, OR, if the history-symbol matches this chart...
           myOrderTicket=OrderTicket();
           myOrderOpenTime=getMyOpenTime(myOrderTicket,OrderOpenTime());
           
           myOrderType = OrderType();
           myOrderLots=OrderLots();
           //myOrderSymbol //already done.
           myOrderOpenPrice=OrderOpenPrice();
           myOrderStopLoss=OrderStopLoss();
           myOrderTakeProfit=OrderTakeProfit();
           
           myOrderCloseTime=OrderCloseTime();
           myOrderClosePrice=OrderClosePrice();
           myOrderCommission=OrderCommission();
           //myOrderTaxes=OrderTaxes(); //No such function
           myOrderSwap=OrderSwap();
           myOrderProfit=OrderProfit();
           myOrderAccount=AccountNumber();
           myOrderMagicNumber=OrderMagicNumber();
           myOrderExpiration=OrderExpiration();
           myOrderComment=OrderComment(); // Comment is last in case it includes a delimiter by accident
           storeMyOpenTime(myOrderComment,myOrderOpenTime);
           
           myOrderDemo=IsDemo();
           if (Make_Dollars_and_LotSize_SECRET)
           {
              if (ConsiderTotalNetProfit) NetProfit = myOrderProfit+myOrderSwap+myOrderCommission;
              else NetProfit = myOrderProfit;
              if (MathAbs(NetProfit) < myOrderLots*BrkEvenTolerance_DollarsPerLot) 
              {  myOrderProfit = BrkEvenTolerance_DollarsPerLot/100; if (NetProfit < 0) myOrderProfit *= -1.0; }
              else if (NetProfit > 0) myOrderProfit = BrkEvenTolerance_DollarsPerLot;
              else myOrderProfit = -1.0*BrkEvenTolerance_DollarsPerLot;
              
              myOrderCommission = 0.0;
              myOrderSwap = 0.0;
              myOrderTaxes = 0.0;
              myOrderLots = 1.0;
           }
        
        }
     } 
     else //if (i==hstTotal && k==openTotal)
     { // This section is to read trades from input filename(s)
        if (rhandle[j] < 0) break;
        
        i--; // to keep i-looping until a forced "break"
        
        // read each field of an entire line.
        // if order = "order", continue
        // adjust times by Shift_Input_TimesBy_Hours*3600
        // Force to use 5-digit(or 3) data, regardless of actual source data (4 or 5 digit). The trailing zeros will be dropped.
        // Since the definition of a "Lot" may be different, scale lot size.
        // if EOF of this file, check ArraySize of rhandle. If another file, j++ & continue, otherwise break
        // NOTE however that a problem with multiple files is they cannot have different Lot and time-shift values.
        
        
        if (FileIsEnding(rhandle[j])) 
        {
           FileClose(rhandle[j]); 
           if (j >= ArraySize(rfiles)-1 ) break;
           else {j++; checkedFirstInputLine = false; continue;} // Increment j. Use continue to start the i-loop over.
        }
        
        if (!checkedFirstInputLine)
        {
          //Check first input line to determine the input file format
          string value1 = FileReadString(rhandle[j]);
          if (!FileIsLineEnding(rhandle[j])) string value2 = FileReadString(rhandle[j]);
          
          inputFileFormat = 5;
          //1st column is "order" and/or 36 total columns. That's V5 format.
          //1st column is "Ticket" and/or total of 14 columns is MT4 report format, compatible with V5
          //if (value1 == "order" || "value1 == "Ticket") do nothing; // Already V5 or compatible formats
          
          //Is file from V4? : 1st column is "account" and/or 35 total columns.
          if (value1 == "account") 
          {
            inputFileFormat = 4;
          }

          //Alert("DEBUG. value1: ",value1,"  value2: ",value2);
          
          if (value1 == "1" && StringFind(value2,":",0) > 0) 
          {
            //File is StrategyTester. 10 columns total. 1st column is "1", 2nd contains ":"
            //Convert the entire file to V5, close old input, change the rhandle[j] value, open the new handle.
            string tmpfile = StringConcatenate("TMP_V5_",rhandle[j],".csv");
            
            FileClose(rhandle[j]);
            
            Alert("Attempting to run convertStratTesterFormatToInput. NOTE, HOWEVER, this library routine has NOT been posted for free/public use by the author, user pips4life of forexfactory.com");
            if (!convertStratTesterFormatToInput(rhandlename[j],InputDelimiter,tmpfile,DefaultInputAccountNumber,DefaultInputSymbolName,StratTestOrderTicketNum_Offset,licensekey1,licensekey2))
                Alert("ERROR. convertStratTesterFormatToInput exited with an error.");
            
            FileClose(rhandle[j]);
            rhandle[j] = FileOpen(tmpfile,FILE_CSV|FILE_READ,"\t");
            if (rhandle[j] < 1) 
            {
               Alert("ERROR. Could not convert StrategyTester input file to regular input file: ",tmpfile);
               j++; checkedFirstInputLine = false; continue; // Increment j. Use continue to start the i-loop over.
            }
            
          }
          
          FileSeek(rhandle[j],0,SEEK_SET); // Reset file position to beginning.
          checkedFirstInputLine = true;
          ArrayResize(origOpenTime,0); // Start with a fresh origOpenTime array with each new input file.
        }
        
        
        string myOrderTypeInputStr;
/*
        if (FileIsEnding(rhandle[j])) continue;
        
        // Read from rhandle[j]; each field, up to one complete line at a time
        // The first field must NOT check using !FileIsLineEnding
        if (inputFileFormat == 4) 
        {
          myOrderAccount=StrToInteger(FileReadString(rhandle[j]));
          if (!FileIsLineEnding(rhandle[j])) myOrderTicket=StrToInteger(FileReadString(rhandle[j]));
        }
        else myOrderTicket=StrToInteger(FileReadString(rhandle[j]));
*/
        string firstReadString = FileReadString(rhandle[j]);
        if (FileIsEnding(rhandle[j])) continue;
        if (StringLen(firstReadString) == 0) 
        {
           // Any line that starts with a blank firstReadString, then ignore the entire line.
           while(!FileIsLineEnding(rhandle[j]))  {discard = FileReadString(rhandle[j]);}
           continue;
        }
        // Read from rhandle[j]; each field, up to one complete line at a time
        // The first field must NOT check using !FileIsLineEnding
        if (inputFileFormat == 4) 
        {
          myOrderAccount=StrToInteger(firstReadString);
          if (!FileIsLineEnding(rhandle[j])) myOrderTicket=StrToInteger(FileReadString(rhandle[j]));
        }
        else myOrderTicket=StrToInteger(firstReadString);
        
        if (!FileIsLineEnding(rhandle[j])) myOrderOpenTime=StrToTime(FileReadString(rhandle[j]));
        myOrderOpenTime=getMyOpenTime(myOrderTicket,myOrderOpenTime);
        
        //if (!FileIsLineEnding(rhandle[j])) myOrderOpenTime=StrToInteger(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderTypeInputStr=stringToLC(FileReadString(rhandle[j]));
        
        if (myOrderTypeInputStr == "buy") myOrderType = OP_BUY;
        else if (myOrderTypeInputStr == "buy limit") myOrderType = OP_BUYLIMIT;
        else if (myOrderTypeInputStr == "buy stop") myOrderType = OP_BUYSTOP;
        else if (myOrderTypeInputStr == "sell") myOrderType = OP_SELL;
        else if (myOrderTypeInputStr == "sell limit") myOrderType = OP_SELLLIMIT;
        else if (myOrderTypeInputStr == "sell stop") myOrderType = OP_SELLSTOP;
        else myOrderType=StrToInteger(myOrderTypeInputStr);
        
        if (!FileIsLineEnding(rhandle[j])) myOrderLots=StrToDouble(FileReadString(rhandle[j])) * Scale_Input_LotSizesBy_Factor;
        if (!FileIsLineEnding(rhandle[j])) myOrderSymbol=stringToUC(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderOpenPrice=StrToDouble(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderStopLoss=StrToDouble(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderTakeProfit=StrToDouble(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderCloseTime=StrToTime(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderClosePrice=StrToDouble(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderCommission=StrToDouble(FileReadString(rhandle[j]));
        if (inputFileFormat >= 5 && !FileIsLineEnding(rhandle[j])) myOrderTaxes=StrToDouble(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderSwap=StrToDouble(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderProfit=StrToDouble(FileReadString(rhandle[j]));
        // The above are the ONLY fields provided by an MT4 report.
        // Specify defaults for fields below in case input file doesn't have the data:
        myOrderClosed = true; // A DEFAULT, in case it's not specified in the data file
        myOrderMagicNumber = 0;
        myOrderExpiration = 0;
        myOrderComment = "";
        myOrderDemo = true;
        myOrderAccount = DefaultInputAccountNumber;
        
        
        if (inputFileFormat >= 5 && !FileIsLineEnding(rhandle[j])) myOrderAccount=StrToInteger(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderMagicNumber=StrToInteger(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderExpiration=StrToTime(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderComment=FileReadString(rhandle[j]);
        storeMyOpenTime(myOrderComment,myOrderOpenTime);
        if (!FileIsLineEnding(rhandle[j])) myOrderClosed=StrToInteger(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderDemo=StrToInteger(FileReadString(rhandle[j]));
        if (!FileIsLineEnding(rhandle[j])) myOrderPoint=StrToDouble(FileReadString(rhandle[j]));
        
        while(!FileIsLineEnding(rhandle[j]))  {discard = FileReadString(rhandle[j]);}
        
        if (Make_Dollars_and_LotSize_SECRET)
        {
           if (ConsiderTotalNetProfit) NetProfit = myOrderProfit+myOrderSwap+myOrderCommission;
           else NetProfit = myOrderProfit;
           if (MathAbs(NetProfit) < myOrderLots*BrkEvenTolerance_DollarsPerLot) 
           {  myOrderProfit = BrkEvenTolerance_DollarsPerLot/100; if (NetProfit < 0) myOrderProfit *= -1.0; }
           else if (NetProfit > 0) myOrderProfit = BrkEvenTolerance_DollarsPerLot;
           else myOrderProfit = -1.0*BrkEvenTolerance_DollarsPerLot;
           
           myOrderCommission = 0.0;
           myOrderSwap = 0.0;
           myOrderTaxes = 0.0;
           myOrderLots = 1.0;
        }
        if (myOrderSymbol == "symbol" || myOrderSymbol == "Item") continue; //Ignore any header lines.  Continue the "i" for-loop.
        if (myOrderLots == 0) continue; //Ignore any transaction with "0" lot-size.  Continue the "i" for-loop.
        if (!myOrderClosed) continue; //Open orders from an input file are SKIPPED (and also NOT included in output file!)
        if (myOrderOpenTime != 0) myOrderOpenTime += infileTimeShiftSec;
        if (myOrderCloseTime != 0) myOrderCloseTime += infileTimeShiftSec;
        if (myOrderExpiration != 0) myOrderExpiration += infileTimeShiftSec;
        
     }
     
     if (OUTPUT_HistoryTo_FileName_CSV != "" || stringToUC(myOrderSymbol) == stringToUC(Symbol()) )
     { 
        // EITHER, we are outputing details and need the calculations,
        //    OR, the order was for the same currency pair as this chart...  so do the work.
        
        if (!myOrderClosed && Show_ClosedOpenAll_Trades_123 > 1)
        {
           if (myOrderType == OP_BUY || myOrderType == OP_BUYSTOP || myOrderType == OP_BUYLIMIT)
                myOrderClosePrice = MarketInfo(myOrderSymbol,MODE_BID);
           else myOrderClosePrice = MarketInfo(myOrderSymbol,MODE_ASK);
           
           // Presumably if the symbol isn't available (because data came from a previous import), then price = 0, so, time = 0 (still)
           if (myOrderClosePrice != 0) myOrderCloseTime = TimeCurrent();
           else myOrderCloseTime = 0;
        }

        // Get the minimum length #-of-lots.  No trailing zeros.
        if (MathMod(myOrderLots*100,10) != 0) LotString = DoubleToStr(myOrderLots,2);
        else if (MathMod(myOrderLots*10,10) != 0) LotString = DoubleToStr(myOrderLots,1);
        else LotString = DoubleToStr(myOrderLots,0);
        
        // Begin time calculations
        if (myOrderCloseTime != 0) NetTime = myOrderCloseTime - myOrderOpenTime;
        else NetTime = TimeCurrent() - myOrderOpenTime; // or should it be: NetTime = 0;
        
        s=NetTime%60;  // Although calculated, the s value is not reported (but see SecStr below).
        m=((NetTime-s)/60)%60;
        h=((NetTime-s-m*60)/3600)%24;
        d=(NetTime-s-m*60-h*3600)/86400; //1day=86400sec
        
        if (h < 10) HourStr = StringConcatenate("0",h);
        else HourStr = h;
        if (m < 10) MinStr = StringConcatenate("0",m);
        else MinStr = m;
        if (s < 10) SecStr = StringConcatenate("0",s);
        else SecStr = s;
        
        //FYI, TimeStrSec is always used in output, w/o leading ", "
        if (d>0) TimeStrSec = StringConcatenate(d,"_",HourStr,":",MinStr,":",SecStr); 
        else TimeStrSec = StringConcatenate(HourStr,":",MinStr,":",SecStr);
        
        if (d>0) TimeStr = StringConcatenate(", ",d,"_",HourStr,":",MinStr);
        else TimeStr = StringConcatenate(", ",HourStr,":",MinStr);
        
        if (ShowTimeString && TimeIncludesSeconds) TimeStr = StringConcatenate(", ",TimeStrSec);
        else if (!ShowTimeString) TimeStr="";
        // end time calcs.  TimeStr may be blank, but TimeStrSec NEVER is. It goes into output file.
        
        // NOTE: My Commission entries are negative, hence they are added.
        // Following does not consider Taxes withheld (because I don't know the function to retrieve it).
        // However, one probably wouldn't want to consider myOrderTaxes in the calculation anyway.
        NetProfit = myOrderProfit+myOrderSwap+myOrderCommission;
        if (ConsiderTotalNetProfit)
        {
          NetOrGrossProfit = NetProfit; // Net profit
          if (!myOrderDemo)
          {
             // Live trades
             if (myOrderClosed) ProfitString = "Net:$ "+DoubleToStr(NetProfit,2);
             else ProfitString = "OPEN:$ "+DoubleToStr(NetProfit,2);
          }
          else
          {
             // Demo trades
             if (myOrderClosed) ProfitString = "*Net:$ "+DoubleToStr(NetProfit,2);
             else ProfitString = "*OPEN:$ "+DoubleToStr(NetProfit,2);
          }
        }
        else
        {
          if (myOrderClosed) NetOrGrossProfit = myOrderProfit; // Gross profit
          if (!myOrderDemo)
          {
             // Live trades
             if (myOrderClosed) ProfitString = "Grs:$ "+DoubleToStr(myOrderProfit,2);
             else ProfitString = "OPEN:$ "+DoubleToStr(myOrderProfit,2);
          }
          else
          {  
             // Demo trades
             if (myOrderClosed) ProfitString = "*Grs:$ "+DoubleToStr(myOrderProfit,2);
             else ProfitString = "*OPEN:$ "+DoubleToStr(myOrderProfit,2);
          }
        }
        
        // Calculate in terms of pips: Profit, S/L and T/P
        NETpips = 0;
        SLpips = 0;
        TPpips = 0;
        SLslip = 0;
        TPadd = 0;
        
        myPoint = getPointForSymbol(false,myOrderSymbol);
        pointdiv10 = myPoint/10.0; // Even on 2/4 brokers, if 3/5 data is imported, this is needed to display 10ths of pips.
        if (AutoPipTenthsFor5DigitBroker && getPointForSymbol(true,myOrderSymbol) != getPointForSymbol(false,myOrderSymbol))
        {
          myPoint = getPointForSymbol(true,myOrderSymbol);
        }
        
        if (myPoint == 0.0)
        {
           if (myOrderPoint != 0.0) myPoint = myOrderPoint;
           else myPoint = 1.0;
           pointdiv10 = myPoint/10.0;
        }
        if (pointdiv10 == 0.0) pointdiv10 = myPoint/10.0;
        
        //if (myPoint == 0.0) Print("DEBUG ERROR. myPoint = 0. myOrderSymbol: ",myOrderSymbol);
        
        if (myOrderType == OP_BUY || myOrderType == OP_BUYSTOP || myOrderType == OP_BUYLIMIT)
        { // This was a Buy order 
           if (myOrderProfit != 0)    NETpips=MathRound((myOrderClosePrice-myOrderOpenPrice)/pointdiv10) * pointdiv10/myPoint;
           if (myOrderStopLoss > 0)   SLpips=MathRound((myOrderStopLoss-myOrderOpenPrice)/pointdiv10) * pointdiv10/myPoint;
           if (myOrderTakeProfit > 0) TPpips=MathRound((myOrderTakeProfit-myOrderOpenPrice)/pointdiv10) * pointdiv10/myPoint;
           if (myOrderProfit != 0 || myOrderOpenPrice == myOrderClosePrice)
           { //Not a cancelled order
              if (myOrderTakeProfit > 0 && myOrderClosePrice > myOrderTakeProfit)
                   TPadd=MathRound((myOrderClosePrice-myOrderTakeProfit)/pointdiv10) * pointdiv10/myPoint;
              if (myOrderStopLoss > 0 && myOrderClosePrice < myOrderStopLoss)
                   SLslip=MathRound((myOrderClosePrice-myOrderStopLoss)/pointdiv10) * pointdiv10/myPoint;
              
              // POSSIBLY zero these out, but if left alone here, they go into the output database. The display is suppressed further below.
              //if ( MathAbs(TPadd) <= MathAbs(SlippageToleranceWithin_Pips) ) TPadd = 0;
              //if ( MathAbs(SLslip) <= MathAbs(SlippageToleranceWithin_Pips) ) SLslip = 0;
           }
        }
        else
        { // This was a Sell order
           if (myOrderProfit != 0)    NETpips=MathRound((myOrderOpenPrice-myOrderClosePrice)/pointdiv10) * pointdiv10/myPoint;
           if (myOrderStopLoss > 0)   SLpips=MathRound((myOrderOpenPrice-myOrderStopLoss)/pointdiv10) * pointdiv10/myPoint;
           if (myOrderTakeProfit > 0) TPpips=MathRound((myOrderOpenPrice-myOrderTakeProfit)/pointdiv10) * pointdiv10/myPoint;        
           if (myOrderProfit != 0 || myOrderOpenPrice == myOrderClosePrice)
           { //Not a cancelled order
              if (myOrderTakeProfit > 0 && myOrderClosePrice < myOrderTakeProfit)
                   TPadd=MathRound((myOrderTakeProfit-myOrderClosePrice)/pointdiv10) * pointdiv10/myPoint;
              if (myOrderStopLoss > 0 && myOrderClosePrice > myOrderStopLoss)
                   SLslip=MathRound((myOrderStopLoss-myOrderClosePrice)/pointdiv10) * pointdiv10/myPoint;
           }
        }
        
        // Find the minimum length string to display the values.  No trailing zeros.
        //BUG: if (MathMod(NETpips*100,10) != 0) NETpipsStr = DoubleToStr(NETpips,2);  // BUG! F.P. roundoff problem. This sometimes reports #.00  (trailing zeros!)
        //if (MathMod(MathRound(NETpips*100),10) != 0) NETpipsStr = DoubleToStr(NETpips,2);  // 1/100ths of pips should probably never occur, and don't waste characters.
        if (MathMod(MathRound(NETpips*10),10) != 0) NETpipsStr = DoubleToStr(NETpips,1); // 1/10ths of pips is normal on extra-digit broker
        else NETpipsStr = DoubleToStr(NETpips,0); // Normal pips, no trailing zeros.
        
        if (MathMod(MathRound(SLpips*10),10) != 0) SLpipsStr = StringConcatenate(" SL: ",DoubleToStr(SLpips,1));
        else if (SLpips != 0) SLpipsStr = StringConcatenate(" SL: ",DoubleToStr(SLpips,0));
        else SLpipsStr = "";
        //else SLpipsStr = " SL: 0";
        
        if (MathMod(MathRound(SLslip*10),10) != 0) SLslipStr = StringConcatenate(" slip ",DoubleToStr(SLslip,1));
        else if (SLslip != 0) SLslipStr = StringConcatenate(" slip ",DoubleToStr(SLslip,0));
        else SLslipStr = "";
        if ( MathAbs(SLslip) <= MathAbs(SlippageToleranceWithin_Pips) ) SLslipStr = "";

        
        if (MathMod(MathRound(TPpips*10),10) != 0) TPpipsStr = StringConcatenate(" TP: ",DoubleToStr(TPpips,1));
        else if (TPpips != 0) TPpipsStr = StringConcatenate(" TP: ",DoubleToStr(TPpips,0));
        else TPpipsStr = "";
        //else TPpipsStr = " TP: 0";
        
        if (MathMod(MathRound(TPadd*10),10) != 0) TPaddStr = StringConcatenate(" add:",DoubleToStr(TPadd,1));
        else if (TPadd != 0) TPaddStr = StringConcatenate(" add:",DoubleToStr(TPadd,0));
        else TPaddStr = "";
        if ( MathAbs(TPadd) <= MathAbs(SlippageToleranceWithin_Pips) ) TPaddStr = "";
        
        
        // Create shortcut text names to use in object descriptions    
        switch(myOrderType)
        {
         case OP_BUY:
            myOrderTypeString = "Buy";
            break;
         case OP_BUYSTOP:
            myOrderTypeString = "BySt";
            break;
         case OP_BUYLIMIT:
            myOrderTypeString = "BLmt";
            break;
         case OP_SELL:
            myOrderTypeString = "Sell";
            break;
         case OP_SELLSTOP:
            myOrderTypeString = "SlSt";
            break;
         case OP_SELLLIMIT:
            myOrderTypeString = "SLmt";
            break;
         case 6:
            //Initial deposit or adjustment, but it's not an order to care about, and "symbol" was blank.
            //Capturing it here prevents a bogus error. Although no objects created, the record WILL be in any output file.
            myOrderTypeString = "Adj"; 
            break;
         default:
           Alert("Possible ERROR: unknown OrderType: ",myOrderType);
           Alert(myOrderTicket," ",TimeToStr(myOrderOpenTime,TIME_DATE|TIME_MINUTES)," ",myOrderSymbol," #",myOrderLots,
              " @",myOrderOpenPrice," cl@",myOrderClosePrice," Grs:$ ",myOrderProfit," ",myOrderComment);
           //myOrderTicket,myOrderOpenTime,myOrderType,myOrderLots,myOrderSymbol,
           //myOrderOpenPrice,myOrderStopLoss,myOrderTakeProfit,myOrderCloseTime,myOrderClosePrice,
           //myOrderCommission,myOrderSwap,myOrderTaxes,myOrderMagicNumber,myOrderExpiration,
           //myOrderComment,...
           //return; // If no return, it can go into an output file and be studied in Excel
        }
        
        OrderName = DoubleToStr(myOrderTicket,0)+" "+TimeToStr(myOrderOpenTime)+" @ "+DoubleToStr(myOrderOpenPrice,Digits)+
              " to "+DoubleToStr(myOrderClosePrice,Digits);
        OrderDescription = NETpipsStr+"p "+SLpipsStr+SLslipStr+TPpipsStr+TPaddStr+"  #"+LotString+"  "+ProfitString+TimeStr;
        // FYI, Max Chars is 62:
        //12345678901234567890123456789012345678901234567890123456789012
        //-1007.4p  SL: 57.2  TP: 100.5  #0.35  Net:$ -3029.70, 12_01:26
        
        //Print("Order ",OrderName," : ",OrderDescription);
        
        
        
        ////////////// Begin section to display texts
        // First figure out at what price to place the text.
        if (myOrderType == OP_BUY || myOrderType == OP_BUYSTOP || myOrderType == OP_BUYLIMIT)
        { // Place Buy text a calculated pips below open price
           PlaceTextAtPrice = (myOrderOpenPrice-TextOffsetBase*myPoint-TextOffsetDelta*TextOffsetCounter*myPoint);
        }
        else
        { // Place Sell text a calculated pips above open price
           PlaceTextAtPrice = (myOrderOpenPrice+TextOffsetBase*myPoint+TextOffsetDelta*TextOffsetCounter*myPoint);
        }
        TextOffsetCounter++;
        if (TextOffsetCounter >= 4) TextOffsetCounter = 0; // Larger number handles more orders at same price/time but offsets grow larger.
          
        ObjName = "_"+myOrderTypeString+"_"+OrderName;
        TextDescription = myOrderTypeString+"_"+DoubleToStr(myOrderTicket,0)+"@"+DoubleToStr(myOrderOpenPrice,Digits)+
            "  "+NETpipsStr+"p #"+LotString+" "+ProfitString+TimeStr;
        //    "  "+NETpips+"p #"+DoubleToStr(myOrderLots,2)+" "+ProfitString+TimeStr;
        //
        //FYI, Max Chars is 62:
        //12345678901234567890123456789012345678901234567890123456789012
        //Sell_2221093@156.19  -201p #0.91 Net:$ -1088.24, 12_00:05
        //Sell_1632772@212.36  -740p #0.31 Net:$ -2080.17, 12_00:13:27
        SetText(myOrderSymbol, ObjName, TextDescription, myOrderOpenTime, PlaceTextAtPrice, TextColor, myOrderCloseTime);
          
        // Possibly adjust text placement above based on the previous text stored here for the next text.
        //LastPlaceTextAtPrice = PlaceTextAtPrice; 
          
        /////////////////// end of text section



        ////////////////// The next DisplayLines section is the most signficant enhancement added to V2:
        
        if (myOrderType == OP_BUY || myOrderType == OP_BUYSTOP || myOrderType == OP_BUYLIMIT)
        { // A Buy Order, either cancelled or positive-profit or negative-profit.
           
          // Is this a cancelled order?
          // Possible alternate for cancelled orders:  if (StringFind(myOrderComment,"cancelled",0) >= 0)
          if (myOrderProfit == 0 && myOrderOpenPrice != myOrderClosePrice)
          { // Draw a Cancelled-Buy trendline
            ObjName = "_C_"+myOrderTypeString+" "+OrderName;
            SetLine(myOrderSymbol, ObjName, OrderDescription, myOrderOpenTime, myOrderOpenPrice-Spread, myOrderCloseTime, 
                myOrderOpenPrice-Spread, CancelledBuyLine, 1, STYLE_SOLID);
          } // end of if it was cancelled
          else 
          { // buy order was not cancelled
              
            // Was this profitable or break-even?
            if (NetOrGrossProfit >= 0)
            {
              // Draw a Positive (profitable or break-even) Buy trendline
              ObjName = "_P_"+myOrderTypeString+" "+OrderName;
              SetLine(myOrderSymbol, ObjName, OrderDescription, myOrderOpenTime, myOrderOpenPrice-Spread, myOrderCloseTime, 
                  myOrderClosePrice, ProfitBuyLine, 3, STYLE_SOLID);
            } 
            else 
            {
              // Draw a Negative (loosing) Buy trendline
              ObjName = "_N_"+myOrderTypeString+" "+OrderName;
              SetLine(myOrderSymbol,ObjName, OrderDescription, myOrderOpenTime, myOrderOpenPrice-Spread, myOrderCloseTime, 
                  myOrderClosePrice, LossBuyLine, 1, STYLE_DASH);              
            } 
          } // end -- a buy was cancelled or not
        } // end all buys
        else 
        {
          // A sell order, either cancelled or positive-profit or negative-profit.
            
          // Is this a cancelled order?
          // Possible alternate for cancelled orders:  if (StringFind(myOrderComment,"cancelled",0) >= 0)
          if (myOrderProfit == 0 && myOrderOpenPrice != myOrderClosePrice)
          {
            // Draw a Cancelled Sell trendline
            ObjName = "_C_"+myOrderTypeString+" "+OrderName;
            SetLine(myOrderSymbol,ObjName, OrderDescription, myOrderOpenTime, myOrderOpenPrice, myOrderCloseTime, 
                myOrderOpenPrice, CancelledSellLine, 1, STYLE_SOLID);
          } // end of if it was cancelled
          else 
          { // order was not cancelled
            // A Sell order
              
            // Was this profitable or break-even?
            if (NetOrGrossProfit >= 0)
            { 
              // Draw a Profitable or Break Even Sell trendline
              ObjName = "_P_"+myOrderTypeString+" "+OrderName;
              SetLine(myOrderSymbol,ObjName, OrderDescription, myOrderOpenTime, myOrderOpenPrice, myOrderCloseTime, 
                  myOrderClosePrice-Spread, ProfitSellLine, 3, STYLE_SOLID);
            } 
            else 
            {
              // Draw a Loosing Sell trendline
              ObjName = "_N_"+myOrderTypeString+" "+OrderName;
              SetLine(myOrderSymbol,ObjName, OrderDescription, myOrderOpenTime, myOrderOpenPrice, myOrderCloseTime, 
                  myOrderClosePrice-Spread, LossSellLine, 1, STYLE_DASH);      
            }               
          } // end non-cancelled sells
        } // end all sells
        ////////////////// end of DisplayLines section 
      
      
      
        ////////////////// Begin DisplayArrows section
        
        if (myOrderType == OP_BUY || myOrderType == OP_BUYSTOP || myOrderType == OP_BUYLIMIT)
        {
          // A Buy Order, either cancelled or break-even or positive-profit or negative-profit.
          // Not, however, currently Open orders (I think).
            
          // For all Buy orders, put down these arrow(s)
            
          // OLD V1: LAST arrow at same time/price will overwrite previous arrows!  Consider the order carefully!
          if (myOrderTakeProfit > 0 && (myOrderClosePrice < myOrderTakeProfit || TPaddStr != "") )
          {
               if (SLslipStr == "") SetArrow(myOrderSymbol,"_B_TP_"+OrderName, OrderDescription, myOrderOpenTime,myOrderTakeProfit,
                    177,ProfitArrow, TRUE, myOrderCloseTime);  // Target arrow for T/P if non-0, but not if closed at T/P
               else SetArrow(myOrderSymbol,"_BC_TPA_"+OrderName, OrderDescription, myOrderCloseTime,myOrderTakeProfit,
                    178,ProfitArrow, TRUE,myOrderOpenTime);  // Target arrow for T/P if non-0, closed at T/P WITH POS-SLIPPAGE
          }
          if (myOrderStopLoss > 0 && (myOrderClosePrice == 0 || myOrderClosePrice > myOrderStopLoss || SLslipStr != "")) 
          {
               if (SLslipStr == "") SetArrow(myOrderSymbol,"_B_SL_"+OrderName, OrderDescription, myOrderOpenTime,myOrderStopLoss,
                    251,SLArrow, TRUE,myOrderCloseTime);  // An "x" arrow for S/L if non-0, but not if closed at S/L
               else SetArrow(myOrderSymbol,"_BC_SLS_"+OrderName, OrderDescription, myOrderCloseTime,myOrderStopLoss,
                    253,SLArrow, TRUE,myOrderOpenTime);  // A boxed-"x" arrow for S/L closed at S/L WITH SLIPPAGE > tolerance
          }
          if (myOrderType == OP_BUY) SetArrow(myOrderSymbol,"_B_"+OrderName, OrderDescription, myOrderOpenTime,myOrderOpenPrice-Spread,
               233,BuyArrow, NULL,myOrderCloseTime);  // Buy arrow
          else if (myOrderType == OP_BUYLIMIT) SetArrow(myOrderSymbol,"_B_"+OrderName, OrderDescription, myOrderOpenTime,myOrderOpenPrice-Spread,
               228,BuyArrow, NULL,myOrderCloseTime);  // BuyLimit 45 slanted arrow
          else if (myOrderType == OP_BUYSTOP) SetArrow(myOrderSymbol,"_B_"+OrderName, OrderDescription, myOrderOpenTime,myOrderOpenPrice-Spread,
               200,BuyArrow, NULL,myOrderCloseTime);  // BuyStop 90 degree bend-up arrow
            
          // Is this a cancelled order?
          // Possible alternate for cancelled orders:  if (StringFind(myOrderComment,"cancelled",0) >= 0)
          if (!myOrderClosed || (myOrderProfit == 0 && myOrderOpenPrice != myOrderClosePrice))
          {
            // If order is still open, OR,...
            // If cancelled, we do no further arrows.  
            // FYI, using the same "if" logic as before makes it easier to maintain the code.
          }
          else 
          { // order was not cancelled
            if (MathAbs(NetOrGrossProfit) < myOrderLots*MathAbs(BrkEvenTolerance_DollarsPerLot) ) // looser +/- definition
            //if (NetOrGrossProfit >= 0 && NetOrGrossProfit <= myOrderLots*MathAbs(BrkEvenTolerance_DollarsPerLot) ) // tighter definition.  ONLY if >=0 and <= tolerance/lot
            { // close at B.E. (break even, or within tolerance-per-lot)
              SetArrow(myOrderSymbol,"_BC_BE_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice,
                   162,ProfitArrow, TRUE,myOrderOpenTime);  // A zero for B.E. close.
            }
            else if (NetOrGrossProfit > 0 )
            { // buy order was profitable
              if (myOrderTakeProfit != 0 && myOrderClosePrice >= myOrderTakeProfit)
              { // close at profit at T/P
                SetArrow(myOrderSymbol,"_BC_TP_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice,
                     74,ProfitArrow, TRUE,myOrderOpenTime);  // A smiley face for T.P. close.
              }
              else if (myOrderStopLoss != 0 && myOrderClosePrice <= myOrderStopLoss)
              { // close at profit at S/L 
                SetArrow(myOrderSymbol,"_BC_SL_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice,
                     254,ProfitArrow, TRUE,myOrderOpenTime);  // A checkmark-in=-a-box for profitable S/L close.
              }
              else 
              { // manually close at profit
                SetArrow(myOrderSymbol,"_BC_Man_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice,
                     252,ProfitArrow, TRUE,myOrderOpenTime);  // A checkmark for profitable manual close.
              }
            }
            else
            { // Profit is negative (a loss).
              if (myOrderStopLoss != 0 && myOrderClosePrice <= myOrderStopLoss)
              { // close at loss at S/L 
                SetArrow(myOrderSymbol,"_BC_SL_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice,
                     78,LossArrow, TRUE,myOrderOpenTime);  // A skull-and-bones(78), or bomb(77), for negative S/L close.
              }
              else if (myOrderTakeProfit != 0 && myOrderClosePrice >= myOrderTakeProfit)
              { // close at loss at a reduced T/P
                SetArrow(myOrderSymbol,"_BC_TP_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice,
                     120,LossArrow, TRUE,myOrderOpenTime);  // A x-in-a-box for negative T.P. close.
              }
              else
              { // manually close at a loss
                SetArrow(myOrderSymbol,"_BC_Man_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice,
                     34,LossArrow, TRUE,myOrderOpenTime);  // A scissors (to cut losses) for a negative manual close
              }              
            } // end profit is negative
          } // end order was not cancelled.
        } // end order is a buy order
        else
        { // Trade is a Sell order, either cancelled or break-even or positive-profit or negative-profit.
            
          // For all Sell orders, put down these arrow(s) //ObjectCreate
            
          // LAST arrow at same time/price will overwrite previous arrows!  Consider the order carefully!
          if (myOrderTakeProfit > 0 && (myOrderClosePrice == 0 || myOrderClosePrice > myOrderTakeProfit || TPaddStr != "")) 
          {
               if (TPaddStr == "") SetArrow(myOrderSymbol,"_S_TP_"+OrderName, OrderDescription, myOrderOpenTime,myOrderTakeProfit,
                    177,ProfitArrow, TRUE,myOrderCloseTime);  // Target arrow for T/P if non-0
               else SetArrow(myOrderSymbol,"_SC_TPA_"+OrderName, OrderDescription, myOrderCloseTime,myOrderTakeProfit,
                    178,ProfitArrow, TRUE,myOrderOpenTime);  // Target arrow for T/P if non-0  POS-SLIPPAGE>tolerance
          }
          if (myOrderStopLoss > 0 && (myOrderClosePrice < myOrderStopLoss  || SLslipStr != "") )
          {
               if (SLslipStr == "") SetArrow(myOrderSymbol,"_S_SL_"+OrderName, OrderDescription, myOrderOpenTime,myOrderStopLoss,
                    251,SLArrow, TRUE,myOrderCloseTime);  // An "x" arrow for S/L if non-0
               else SetArrow(myOrderSymbol,"_SC_SLS_"+OrderName, OrderDescription, myOrderCloseTime,myOrderStopLoss,
                    253,SLArrow, TRUE,myOrderOpenTime);  // An boxed-"x" arrow for S/L if non-0  SLIPPAGE>tolerance
          }
          if (myOrderType == OP_SELL) SetArrow(myOrderSymbol,"_S_"+OrderName, OrderDescription, myOrderOpenTime,myOrderOpenPrice,
               234,SellArrow, NULL,myOrderCloseTime);  // Sell arrow
          else if (myOrderType == OP_SELLLIMIT) SetArrow(myOrderSymbol,"_S_"+OrderName, OrderDescription, myOrderOpenTime,myOrderOpenPrice,
               230,SellArrow, NULL,myOrderCloseTime);  // BuyLimit 45 slanted arrow
          else if (myOrderType == OP_SELLSTOP) SetArrow(myOrderSymbol,"_S_"+OrderName, OrderDescription, myOrderOpenTime,myOrderOpenPrice,
               202,SellArrow, NULL,myOrderCloseTime);  // BuyStop 90 degree bend-up arrow
            
          // Is this a cancelled order?
          // Possible alternate for cancelled orders:  if (StringFind(myOrderComment,"cancelled",0) >= 0)
          if (!myOrderClosed || (myOrderProfit == 0 && myOrderOpenPrice != myOrderClosePrice))
          {
            // If order is still open, OR, ...
            // If cancelled, we do no further arrows.  
            // FYI, using the same "if" logic as before makes it easier to maintain the code.
          }
          else 
          { // sell order was not cancelled
            if (MathAbs(NetOrGrossProfit) < myOrderLots*MathAbs(BrkEvenTolerance_DollarsPerLot) ) // looser +/- definition
            //if (NetOrGrossProfit >= 0 && NetOrGrossProfit <= myOrderLots*MathAbs(BrkEvenTolerance_DollarsPerLot) ) // tighter definition.  ONLY if >=0 and <= tolerance/lot
            { // close at B.E. (break even, or within tolerance-per-lot)
              SetArrow(myOrderSymbol,"_SC_BE_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice-Spread,
                   162,ProfitArrow, TRUE,myOrderOpenTime);  // A zero for B.E. close.
            }
            else if (NetOrGrossProfit > 0 )
            { // sell order was profitable
              if (myOrderTakeProfit != 0 && myOrderClosePrice <= myOrderTakeProfit)
              { // close at profit at T/P
                SetArrow(myOrderSymbol,"_SC_TP_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice-Spread,
                     74,ProfitArrow, TRUE,myOrderOpenTime);  // A smiley face for T.P. close.
              }
              else if (myOrderStopLoss != 0 && myOrderClosePrice >= myOrderStopLoss)
              { // close at profit at S/L 
                SetArrow(myOrderSymbol,"_SC_SL_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice-Spread,
                     254,ProfitArrow, TRUE,myOrderOpenTime);  // A checkmark-in=-a-box for profitable S/L close.
              }
              else 
              { // manually close at profit
                SetArrow(myOrderSymbol,"_SC_Man_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice-Spread,
                     252,ProfitArrow, TRUE,myOrderOpenTime);  // A checkmark for profitable manual close.
              }
            }
            else
            { // Profit is negative.
              if (myOrderStopLoss != 0 && myOrderClosePrice >= myOrderStopLoss)
              { // close at loss at S/L 
                SetArrow(myOrderSymbol,"_SC_SL_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice-Spread,
                     78,LossArrow, TRUE,myOrderOpenTime);  // A skull-and-bones(78), or bomb(77), for negative S/L close.
              }
              else if (myOrderTakeProfit != 0 && myOrderClosePrice-Spread <= myOrderTakeProfit)
              { // close at loss at a reduced T/P
                SetArrow(myOrderSymbol,"_SC_TP_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice-Spread,
                    120,LossArrow, TRUE,myOrderOpenTime);  // A x-in-a-box for negative T.P. close.
              }
              else
              { // manually close at a loss
                SetArrow(myOrderSymbol,"_SC_Man_"+OrderName, OrderDescription, myOrderCloseTime,myOrderClosePrice-Spread,
                    34,LossArrow, TRUE,myOrderOpenTime);  // A scissors (to cut losses) for a negative manual close
              }              
            } // end profit is negative
          } // end order was not cancelled.
        } // end of sell Orders.    
        // end of DisplayArrows section
          
          
     } // end OrderSymbol
     
     // Write data and calculation to output file?
     if (OUTPUT_HistoryTo_FileName_CSV != "" && whandle >=1 && (OUTPUT_DataFor_ALL_Symbols || stringToUC(myOrderSymbol) == stringToUC(Symbol()) ))
     {
        if (!myOrderClosed)
        {
           // Order was not truly closed so remove the temporary values used for calculations above.
           myOrderClosePrice = 0;
           myOrderCloseTime = 0;
        }
        
        if (myOrderOpenTime < starttime || myOrderOpenTime > endtime) continue;
        if (RequireCloseWithinDateRange && ( myOrderCloseTime < starttime || myOrderCloseTime > endtime)) continue;
        
        // Not a big deal, but account actions like deposits or commissions
        // charged -- everything with a blank symbol name -- are suppressed
        // from the output file if SECRET=true
        if (myOrderSymbol == "" && (Make_Dollars_and_LotSize_SECRET || OUTPUT_SuppressBlankSymbolLines)) continue; 
        
        if (myOrderOpenTime != 0) myOrderOpenTime += outfileTimeShiftSec;
        if (myOrderCloseTime != 0) myOrderCloseTime += outfileTimeShiftSec;
        if (myOrderExpiration != 0) myOrderExpiration += outfileTimeShiftSec;
        
        FileWrite(whandle,myOrderTicket,
             TimeToStr(myOrderOpenTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             myOrderType,
             myOrderLots * Scale_OUTPUT_LotSizesBy_Factor,
             myOrderSymbol,myOrderOpenPrice,myOrderStopLoss,myOrderTakeProfit,
             TimeToStr(myOrderCloseTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             myOrderClosePrice,myOrderCommission,myOrderTaxes,myOrderSwap,myOrderProfit,
             myOrderAccount,myOrderMagicNumber,
             TimeToStr(myOrderExpiration,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             myOrderComment,myOrderClosed,myOrderDemo,myPoint,
             "","","", // placeholders for future data
             myOrderTypeString,NetProfit,NETpips,SLpips,TPpips,TimeStrSec,NetTime,SLslip,TPadd,
             myOrderOpenTime,myOrderCloseTime,myOrderExpiration);
     }
     
  } // end for hstTotal loop to process all orders
  
  
  if (whandle >= 1) 
  {
     FileClose(whandle);
     Alert("Created output: ",TerminalPath(),"\\experts\files\\",OUTPUT_HistoryTo_FileName_CSV,"  (",OUTPUT_File_Delimiter," delimited)");
  }
  
  if (rhandle[0] >= 1)
  {
     for (j=0; j<ArraySize(rfiles); j++)
     {
        FileClose(rhandle[j]);
     }
  }
  
  if (!obj_created)
  {
     Alert("... If using input file(s), check for correct name, format, 1st-data-header-line, delimiter, symbol, etc.");
     Alert("... Also confirm any custom Start_Date_OR_Number_of_weeks and End_Date_OR_Number_of_weeks variable settings are the correct range.");
     Alert("No trades displayed for this chart symbol! Open the View->Terminal window. Select AccountHistory tab. Change CustomPeriod.");
  }

//int count = ArrayRange(origOpenTime,0);
//Alert("DEBUG  count: ",count);
//for (j=0; j<count; j++)
//{
//   Alert("DEBUG  j: ",j,"  [0]: ",origOpenTime[j][0],"  [1]: ",origOpenTime[j][1],"   ",TimeToStr(origOpenTime[j][1],TIME_DATE|TIME_MINUTES) );
//}

  //----
  return(0);
} // end start





//+------------------------------------------------------------------+
double getPointForSymbol(bool custommode, string symbol)
{
   double point = MarketInfo(symbol,MODE_POINT);
   if (symbol == "") return(0.0);
   //string symbol = Symbol();
   int pluspos = StringFind(symbol,"+",0);
   int minuspos = StringFind(symbol,"-",0);
   if (pluspos > 0) symbol = StringSubstr(symbol,0,pluspos);
   else if (minuspos > 0) symbol = StringSubstr(symbol,0,minuspos);
   
   if (! custommode) return(point);
   else
     {
      if (symbol == "NOKJPY" || symbol == "SEKJPY" || symbol == "GBPDKK" 
          || symbol == "GBPNOK" || symbol == "USDSKK" || symbol == "XAG") point = MarketInfo(symbol,MODE_POINT); // These are 0.001 on BroCo.
      else if (StringFind(symbol,"JPY",3) == 3 || symbol == "XAUUSD") point = 0.01; // ***JPY, XAUUSD
      else if (StringFind(symbol,"USD",0) >= 0
               || StringFind(symbol,"EUR",0) >= 0
               || StringFind(symbol,"GBP",0) >= 0
               || StringFind(symbol,"CAD",0) >= 0
              ) point = 0.0001;
     }
   //Print("getPoint: ",point,"  symbol: ",symbol);
   return(point);
} // end of getPoint

//+------------------------------------------------------------------+
void stringSplitBySpaces (string& output[], string s_input) 
{
   int pos, arraysize;
   ArrayResize(output, 0);
   s_input = StringTrimLeft(StringTrimRight(s_input));  // Leading/trailing spaces must be stripped off first.
   while (true) 
     {
      pos = StringFind(s_input, " ");
      arraysize = ArraySize(output);
      ArrayResize(output, arraysize + 1);
      if (pos != -1) 
        {
         output[arraysize] = StringTrimLeft(StringTrimRight(StringSubstr(s_input, 0, pos)));
         s_input = StringTrimLeft(StringTrimRight(StringSubstr(s_input, pos + 1)));
        } else {
         output[arraysize] = StringTrimLeft(StringTrimRight(s_input));
         break;
        } // if
    } // while
} // end of stringSplitBySpaces

//+------------------------------------------------------------------+
string stringToUC(string str) {
    // Convert str to upper-case
    int lS = 97, lE = 122, uS = 65, uE = 90, diff = lS - uS;
    for (int i = 0; i < StringLen(str); i++) {
        int code = StringGetChar(str, i);
        if (code >= lS && code <= lE) {
            code -= diff;
            str = StringSetChar(str, i, code);
        }
    }
    return (str);
} // end of stringToUC

//+------------------------------------------------------------------+
string stringToLC(string str) {
   // Convert str to upper-case
   int lS = 97, lE = 122, uS = 65, uE = 90, diff = lS - uS;
   for (int i = 0; i < StringLen(str); i++) {
       int code = StringGetChar(str, i);
       if (code >= uS && code <= uE) {
           code += diff;
           str = StringSetChar(str, i, code);
       }
   }
   return (str);
} // end of stringToLC

//+------------------------------------------------------------------+
datetime getMyOpenTime(datetime myOrderTicket,datetime myOrderOpenTime)           
{
   int origOT_count = ArrayRange(origOpenTime,0);
   if (AutoFixOpenTimeForSplitOrders)
   {
      for (int i=0; i<origOT_count; i++)
      {
         if (myOrderTicket < origOpenTime[i][0]) break;
         if (myOrderTicket == origOpenTime[i][0]) { myOrderOpenTime = origOpenTime[i][1]; break; }
      }
   }
   return (myOrderOpenTime);
} // end of getMyOpenTime

//+------------------------------------------------------------------+
void storeMyOpenTime(string myOrderComment, datetime myOrderOpenTime)           
{
   int pos;
   int myOrderTicket;
   if (!AutoFixOpenTimeForSplitOrders) return;
   
   pos = StringFind(myOrderComment,"to #",0);
   if (pos < 0) return;

   myOrderTicket = StrToInteger(StringSubstr(myOrderComment,pos+4));
   
   int origOT_count = ArrayRange(origOpenTime,0);
   int numelements = ArrayResize(origOpenTime,origOT_count+1);
   origOpenTime[origOT_count][0] = myOrderTicket;
   origOpenTime[origOT_count][1] = myOrderOpenTime;
   
   ArraySort(origOpenTime,WHOLE_ARRAY,0,MODE_ASCEND);
   
   return;
} // end of storeMyOpenTime

//+------------------------------------------------------------------+

