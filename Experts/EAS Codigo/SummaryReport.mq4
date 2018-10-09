//+------------------------------------------------------------------+
//|                                                SummaryReport.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#define OP_BALANCE 6
#define OP_CREDIT  7

double InitialDeposit;
double SummaryProfit;
double GrossProfit;
double GrossLoss;
double MaxProfit;
double MinProfit;
double ConProfit1;
double ConProfit2;
double ConLoss1;
double ConLoss2;
double MaxLoss;
double MaxDrawdown;
double MaxDrawdownPercent;
double RelDrawdownPercent;
double RelDrawdown;
double ExpectedPayoff;
double ProfitFactor;
double AbsoluteDrawdown;
int    SummaryTrades;
int    ProfitTrades;
int    LossTrades;
int    ShortTrades;
int    LongTrades;
int    WinShortTrades;
int    WinLongTrades;
int    ConProfitTrades1;
int    ConProfitTrades2;
int    ConLossTrades1;
int    ConLossTrades2;
int    AvgConWinners;
int    AvgConLosers;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateSummary(double initial_deposit)
  {
   int    sequence=0, profitseqs=0, lossseqs=0;
   double sequential=0.0, prevprofit=EMPTY_VALUE, drawdownpercent, drawdown;
   double maxpeak=initial_deposit, minpeak=initial_deposit, balance=initial_deposit;
   int    trades_total=HistoryTotal();
//---- initialize summaries
   InitializeSummaries(initial_deposit);
//----
   for(int i=0; i<trades_total; i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      int type=OrderType();
      //---- initial balance not considered
      if(i==0 && type==OP_BALANCE) continue;
      //---- calculate profit
      double profit=OrderProfit()+OrderCommission()+OrderSwap();
      balance+=profit;
      //---- drawdown check
      if(maxpeak<balance)
        {
         drawdown=maxpeak-minpeak;
         if(maxpeak!=0.0)
           {
            drawdownpercent=drawdown/maxpeak*100.0;
            if(RelDrawdownPercent<drawdownpercent)
              {
               RelDrawdownPercent=drawdownpercent;
               RelDrawdown=drawdown;
              }
           }
         if(MaxDrawdown<drawdown)
           {
            MaxDrawdown=drawdown;
            if(maxpeak!=0.0) MaxDrawdownPercent=MaxDrawdown/maxpeak*100.0;
            else MaxDrawdownPercent=100.0;
           }
         maxpeak=balance;
         minpeak=balance;
        }
      if(minpeak>balance) minpeak=balance;
      if(MaxLoss>balance) MaxLoss=balance;
      //---- market orders only
      if(type!=OP_BUY && type!=OP_SELL) continue;
      //---- calculate profit in points
      // profit=(OrderClosePrice()-OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT);
      SummaryProfit+=profit;
      SummaryTrades++;
      if(type==OP_BUY) LongTrades++;
      else             ShortTrades++;
      //---- loss trades
      if(profit<0)
        {
         LossTrades++;
         GrossLoss+=profit;
         if(MinProfit>profit) MinProfit=profit;
         //---- fortune changed
         if(prevprofit!=EMPTY_VALUE && prevprofit>=0)
           {
            if(ConProfitTrades1<sequence ||
               (ConProfitTrades1==sequence && ConProfit2<sequential))
              {
               ConProfitTrades1=sequence;
               ConProfit1=sequential;
              }
            if(ConProfit2<sequential ||
               (ConProfit2==sequential && ConProfitTrades1<sequence))
              {
               ConProfit2=sequential;
               ConProfitTrades2=sequence;
              }
            profitseqs++;
            AvgConWinners+=sequence;
            sequence=0;
            sequential=0.0;
           }
        }
      //---- profit trades (profit>=0)
      else
        {
         ProfitTrades++;
         if(type==OP_BUY)  WinLongTrades++;
         if(type==OP_SELL) WinShortTrades++;
         GrossProfit+=profit;
         if(MaxProfit<profit) MaxProfit=profit;
         //---- fortune changed
         if(prevprofit!=EMPTY_VALUE && prevprofit<0)
           {
            if(ConLossTrades1<sequence ||
               (ConLossTrades1==sequence && ConLoss2>sequential))
              {
               ConLossTrades1=sequence;
               ConLoss1=sequential;
              }
            if(ConLoss2>sequential ||
               (ConLoss2==sequential && ConLossTrades1<sequence))
              {
               ConLoss2=sequential;
               ConLossTrades2=sequence;
              }
            lossseqs++;
            AvgConLosers+=sequence;
            sequence=0;
            sequential=0.0;
           }
        }
      sequence++;
      sequential+=profit;
      //----
      prevprofit=profit;
     }
//---- final drawdown check
   drawdown=maxpeak-minpeak;
   if(maxpeak!=0.0)
     {
      drawdownpercent=drawdown/maxpeak*100.0;
      if(RelDrawdownPercent<drawdownpercent)
        {
         RelDrawdownPercent=drawdownpercent;
         RelDrawdown=drawdown;
        }
     }
   if(MaxDrawdown<drawdown)
     {
      MaxDrawdown=drawdown;
      if(maxpeak!=0) MaxDrawdownPercent=MaxDrawdown/maxpeak*100.0;
      else MaxDrawdownPercent=100.0;
     }
//---- consider last trade
   if(prevprofit!=EMPTY_VALUE)
     {
      profit=prevprofit;
      if(profit<0)
        {
         if(ConLossTrades1<sequence ||
            (ConLossTrades1==sequence && ConLoss2>sequential))
           {
            ConLossTrades1=sequence;
            ConLoss1=sequential;
           }
         if(ConLoss2>sequential ||
            (ConLoss2==sequential && ConLossTrades1<sequence))
           {
            ConLoss2=sequential;
            ConLossTrades2=sequence;
           }
         lossseqs++;
         AvgConLosers+=sequence;
        }
      else
        {
         if(ConProfitTrades1<sequence ||
            (ConProfitTrades1==sequence && ConProfit2<sequential))
           {
            ConProfitTrades1=sequence;
            ConProfit1=sequential;
           }
         if(ConProfit2<sequential ||
            (ConProfit2==sequential && ConProfitTrades1<sequence))
           {
            ConProfit2=sequential;
            ConProfitTrades2=sequence;
           }
         profitseqs++;
         AvgConWinners+=sequence;
        }
     }
//---- collecting done
   double dnum, profitkoef=0.0, losskoef=0.0, avgprofit=0.0, avgloss=0.0;
//---- average consecutive wins and losses
   dnum=AvgConWinners;
   if(profitseqs>0) AvgConWinners=dnum/profitseqs+0.5;
   dnum=AvgConLosers;
   if(lossseqs>0)   AvgConLosers=dnum/lossseqs+0.5;
//---- absolute values
   if(GrossLoss<0.0) GrossLoss*=-1.0;
   if(MinProfit<0.0) MinProfit*=-1.0;
   if(ConLoss1<0.0)  ConLoss1*=-1.0;
   if(ConLoss2<0.0)  ConLoss2*=-1.0;
//---- profit factor
   if(GrossLoss>0.0) ProfitFactor=GrossProfit/GrossLoss;
//---- expected payoff
   if(ProfitTrades>0) avgprofit=GrossProfit/ProfitTrades;
   if(LossTrades>0)   avgloss  =GrossLoss/LossTrades;
   if(SummaryTrades>0)
     {
      profitkoef=1.0*ProfitTrades/SummaryTrades;
      losskoef=1.0*LossTrades/SummaryTrades;
      ExpectedPayoff=profitkoef*avgprofit-losskoef*avgloss;
     }
//---- absolute drawdown
   AbsoluteDrawdown=initial_deposit-MaxLoss;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitializeSummaries(double initial_deposit)
  {
   InitialDeposit=initial_deposit;
   MaxLoss=initial_deposit;
   SummaryProfit=0.0;
   GrossProfit=0.0;
   GrossLoss=0.0;
   MaxProfit=0.0;
   MinProfit=0.0;
   ConProfit1=0.0;
   ConProfit2=0.0;
   ConLoss1=0.0;
   ConLoss2=0.0;
   MaxDrawdown=0.0;
   MaxDrawdownPercent=0.0;
   RelDrawdownPercent=0.0;
   RelDrawdown=0.0;
   ExpectedPayoff=0.0;
   ProfitFactor=0.0;
   AbsoluteDrawdown=0.0;
   SummaryTrades=0;
   ProfitTrades=0;
   LossTrades=0;
   ShortTrades=0;
   LongTrades=0;
   WinShortTrades=0;
   WinLongTrades=0;
   ConProfitTrades1=0;
   ConProfitTrades2=0;
   ConLossTrades1=0;
   ConLossTrades2=0;
   AvgConWinners=0;
   AvgConLosers=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateInitialDeposit()
  {
   double initial_deposit=AccountBalance();
//----
   for(int i=HistoryTotal()-1; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      int type=OrderType();
      //---- initial balance not considered
      if(i==0 && type==OP_BALANCE) break;
      if(type==OP_BUY || type==OP_SELL)
        {
         //---- calculate profit
         double profit=OrderProfit()+OrderCommission()+OrderSwap();
         //---- and decrease balance
         initial_deposit-=profit;
        }
      if(type==OP_BALANCE || type==OP_CREDIT)
         initial_deposit-=OrderProfit();
     }
//----
   return(initial_deposit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteReport(string report_name)
  {
   int handle=FileOpen(report_name,FILE_CSV|FILE_WRITE,'\t');
   if(handle<1) return;
//----
   FileWrite(handle,"Initial deposit           ",InitialDeposit);
   FileWrite(handle,"Total net profit          ",SummaryProfit);
   FileWrite(handle,"Gross profit              ",GrossProfit);
   FileWrite(handle,"Gross loss                ",GrossLoss);
   if(GrossLoss>0.0)
      FileWrite(handle,"Profit factor             ",ProfitFactor);
   FileWrite(handle,"Expected payoff           ",ExpectedPayoff);
   FileWrite(handle,"Absolute drawdown         ",AbsoluteDrawdown);
   FileWrite(handle,"Maximal drawdown          ",MaxDrawdown,StringConcatenate("(",MaxDrawdownPercent,"%)"));
   FileWrite(handle,"Relative drawdown         ",StringConcatenate(RelDrawdownPercent,"%"),StringConcatenate("(",RelDrawdown,")"));
   FileWrite(handle,"Trades total                 ",SummaryTrades);
   if(ShortTrades>0)
      FileWrite(handle,"Short positions(won %)    ",ShortTrades,StringConcatenate("(",100.0*WinShortTrades/ShortTrades,"%)"));
   if(LongTrades>0)
      FileWrite(handle,"Long positions(won %)     ",LongTrades,StringConcatenate("(",100.0*WinLongTrades/LongTrades,"%)"));
   if(ProfitTrades>0)
      FileWrite(handle,"Profit trades (% of total)",ProfitTrades,StringConcatenate("(",100.0*ProfitTrades/SummaryTrades,"%)"));
   if(LossTrades>0)
      FileWrite(handle,"Loss trades (% of total)  ",LossTrades,StringConcatenate("(",100.0*LossTrades/SummaryTrades,"%)"));
   FileWrite(handle,"Largest profit trade      ",MaxProfit);
   FileWrite(handle,"Largest loss trade        ",-MinProfit);
   if(ProfitTrades>0)
      FileWrite(handle,"Average profit trade      ",GrossProfit/ProfitTrades);
   if(LossTrades>0)
      FileWrite(handle,"Average loss trade        ",-GrossLoss/LossTrades);
   FileWrite(handle,"Average consecutive wins  ",AvgConWinners);
   FileWrite(handle,"Average consecutive losses",AvgConLosers);
   FileWrite(handle,"Maximum consecutive wins (profit in money)",ConProfitTrades1,StringConcatenate("(",ConProfit1,")"));
   FileWrite(handle,"Maximum consecutive losses (loss in money)",ConLossTrades1,StringConcatenate("(",-ConLoss1,")"));
   FileWrite(handle,"Maximal consecutive profit (count of wins)",ConProfit2,StringConcatenate("(",ConProfitTrades2,")"));
   FileWrite(handle,"Maximal consecutive loss (count of losses)",-ConLoss2,StringConcatenate("(",ConLossTrades2,")"));
//----
   FileClose(handle);
  }
//+------------------------------------------------------------------+

