
#property copyright "Copyright © 2005-2006, RickD"
#property link      "http://www.e2e-fx.net"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#define BY_TICKET           1
#define BY_OPENTIME         2
#define BY_TYPE             3
#define BY_LOTS             4
#define BY_SYMBOL           5
#define BY_OPENPRICE        6
#define BY_SL               7
#define BY_TP               8
#define BY_CLOSETIME        9
#define BY_CLOSEPRICE      10
#define BY_COMMISSION      11
#define BY_SWAP            12
#define BY_PROFIT          13
#define BY_COMMENT         14

#define ASC                 1
#define DESC                2


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Это можно и нужно менять
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#define SHOW_OPENTIME       1
#define SHOW_OPENPRICE      1
#define SHOW_SL             1
#define SHOW_TP             1
#define SHOW_CLOSETIME      1
#define SHOW_CLOSEPRICE     1
#define SHOW_COMMISSION     1
#define SHOW_SWAP           1
#define SHOW_COMMENT        0

#define SHOW_STAT_EX        1


int SortBy[] = {BY_CLOSETIME};
int SortBy2[] = {ASC};
//int SortBy[] = {BY_SYMBOL, BY_PROFIT};


bool Validate(int ticket) {

//  if (StringFind(OrderComment(), "[tp]") == -1) return(true);
//  if (OrderOpenTime() < StrToTime("2005.05.27 22.20")) return(false); 
//  if (OrderOpenTime() > StrToTime("2005.06.13 20.00")) return(false); 
//  if (TimeDay(OrderOpenTime()) == 13) return(true);
//  if (OrderProfit() >= 0) return(true);
//  return (OrderSymbol() != "GBPUSD");
  
  return (true);  
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Конец зоны для внесения изменений
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int h1;
int Tickets[];
int sort_type;
int t_ind;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int init() {
  string fname = AccountName() + "_rep.htm";  
  h1 = FileOpen(fname, FILE_WRITE|FILE_CSV);
  if (h1 < 0) {
    Alert("File open error ", GetLastError());
    return(0);
  }
  
  int size = ArraySize(SortBy);
  int size2 = ArraySize(SortBy2);
  if (size2 < size) {
    ArrayResize(SortBy2, size);
  }
  
  for (int i=0; i < size; i++) {
    if (SortBy2[i] != ASC && SortBy2[i] != DESC) SortBy2[i] = ASC;
  }

  return(0);
}

void deinit(){
  FileClose(h1);
  Alert("Done.");
  return(0);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int start() {
  Head();
  Body();
  Tail();
  return(0);
}

void Head() {
  string acc_num = AccountNumber();
  string acc_name = AccountName();
    
  string res =
    "<html><head>\n" +
    "<meta http-equiv=\"Pragma\" content=\"no-cache\">" +
    "<title>Statement: \'" + acc_num + " \', " + acc_name + "</title>\n" +     
    "<style type=\"text/css\" media=\"screen\">\n" +
    "td {font: 8pt Tahoma,Arial;}\n" +
    ".td1 {padding-left:3px; padding-right:3px;}\n" +
    "</style>\n" +
    "<style type=\"text/css\" media=\"print\">\n" +
    "td {font: 7pt Tahoma,Arial; }\n" +
    "</style>\n" +
    "</head>\n" +
    "<body topmargin=1 marginheight=1>\n" +
    "<div align=center>\n" +
    "<div style=\"font: 20pt Times New Roman\"><b>Alpari Ltd. (by RickD)</b></div>\n" +
    "<font face=\"tahoma,arial\" size=1>\n" +
    "<table cellspacing=1 cellpadding=2 border=0>\n" +

    "<tr>" +
      "<td colspan=2>A/C No: <b>" + acc_num + "</b></td>" +
      "<td colspan=6>Name: <b>" + acc_name + "</b></td>" +
      "<td colspan=5 align=right>" + TimeToStr(LocalTime()) + " (local time)</td>" +
    "</tr>\n" +
    "<tr><td colspan=13 style=\"font: 1pt arial\">&nbsp;</td></tr>\n" +
    "<tr><td colspan=13><b>Closed Transactions:</b></td></tr>\n" +

    "<tr align=center bgcolor=#c0c0c0>";
  
  res = res + "<td>N</td>";  
  res = res + "<td>Ticket</td>";
  if (SHOW_OPENTIME == 1) res = res + "<td nowrap>Open Time</td>";
  res = res + "<td>Type</td>";
  res = res + "<td>Lots</td>";
  res = res + "<td>Symbol</td>";
  if (SHOW_OPENPRICE == 1) res = res + "<td nowrap>Price</td>";
  if (SHOW_SL == 1) res = res + "<td>S/L</td>";
  if (SHOW_TP == 1) res = res + "<td>T/P</td>";
  if (SHOW_CLOSETIME == 1) res = res + "<td nowrap>Close Time</td>";
  if (SHOW_CLOSEPRICE == 1) res = res + "<td nowrap>Price</td>";
  if (SHOW_COMMISSION == 1) res = res + "<td>Commis</td>";
  if (SHOW_SWAP == 1) res = res + "<td>Swap</td>";
  res = res + "<td>Trade P/L</td>";     
  if (SHOW_COMMENT == 1) res = res + "<td>Comment</td>";
  res = res + "</tr>\n";
    
  FileWrite(h1, res);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void Body() {
  int ticket, prec;
  string res, fmt;
  double depo = 0;
  double comm = 0; 
  double swap = 0; 
  double profit = 0;
  double loss = 0;  
  double max_win = 0;
  double max_loss = 0;

  int cons_win_cnt = 0;
  int cons_los_cnt = 0;    
  double cons_win_sum = 0;
  double cons_los_sum = 0;  
  
  int mc_winners_cnt = 0;
  int mc_losers_cnt = 0;  
  double mc_winners_sum = 0;
  double mc_losers_sum = 0;
  
  int mc_profit_cnt = 0;
  int mc_loss_cnt = 0; 
  double mc_profit_sum = 0;
  double mc_loss_sum = 0;
   
  double max_summ_pl = 0;
  double min_summ_pl = 0;
  double max_dd = 0;
  double max_dd2 = 0;
  
  double val;
  int ind = 0;
  int num = 1;
  int pos_cnt = 0;
  int neg_cnt = 0;
  
  int cnt = HistoryTotal();
  ArrayResize(Tickets, cnt);
  for (int i=0; i < cnt; i++) {
    OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
    if (OrderComment() == "Deposit") depo += OrderProfit();
    
    ticket = OrderTicket();
    if (Validate(ticket)) {
      Tickets[ind] = ticket;
      ind++;
    }
  }
  
  ArrayResize(Tickets, ind);
  Sort();
 
  string fmt00 = "mso-number-format:0\.00;";
 
  cnt = ArraySize(Tickets); 
  for (i=0; i < cnt; i++) {
    OrderSelect(Tickets[i], SELECT_BY_TICKET, MODE_HISTORY);  
 
    prec = MarketInfo(OrderSymbol(), MODE_DIGITS);
    if (prec == 0) prec = 4;    
  
    fmt = "mso-number-format:0\.";
    for (int j=0; j < prec; j++) fmt = fmt + "0";
   
    res = "<tr ";
    if (MathMod(i, 2) == 1) res = res + "bgcolor=#E0E0E0 ";
    res = res + "align=right>";
    
    res = res + "<td>" + num + "</td>";
    res = res + "<td class=\"td1\" title=\"" + OrderTicket() + "\">" + OrderTicket() + "</td>";
    if (SHOW_OPENTIME == 1) res = res + "<td class=\"td1\" nowrap>" + TimeToStr(OrderOpenTime()) + "</td>";
    
    if (OrderComment() == "Deposit") {
      res = res + "<td>balance</td>";
      res = res + "<td colspan=2 align=left>Deposit</td>";
      if (SHOW_OPENPRICE == 1) res = res + "<td></td>";
      if (SHOW_SL == 1) res = res + "<td></td>";
      if (SHOW_TP == 1) res = res + "<td></td>";
      if (SHOW_CLOSETIME == 1) res = res + "<td></td>";
      if (SHOW_CLOSEPRICE == 1) res = res + "<td></td>";
      if (SHOW_COMMISSION == 1) res = res + "<td></td>";
      if (SHOW_SWAP == 1) res = res + "<td></td>";
    } else {
      
      res = res + "<td class=\"td1\">" + TypeMnem(OrderType()) + "</td>";
      res = res + "<td class=\"td1\" style=" + fmt00 + ">" + DoubleToStr(OrderLots(), 2) + "</td>";
      res = res + "<td class=\"td1\">" + ToLower(OrderSymbol()) + "</td>";
      if (SHOW_OPENPRICE == 1) res = res + "<td class=\"td1\" style=" + fmt + ">" + DoubleToStr(OrderOpenPrice(), prec) + "</td>";
      if (SHOW_SL == 1) res = res + "<td class=\"td1\" style=" + fmt + ">" + DoubleToStr(OrderStopLoss(), prec) + "</td>";
      if (SHOW_TP == 1) res = res + "<td class=\"td1\" style=" + fmt + ">" + DoubleToStr(OrderTakeProfit(), prec) + "</td>";
      if (SHOW_CLOSETIME == 1) res = res + "<td class=\"td1\" nowrap>" + TimeToStr(OrderCloseTime()) + "</td>";
      if (SHOW_CLOSEPRICE == 1) res = res + "<td class=\"td1\" style=" + fmt + ">" + DoubleToStr(OrderClosePrice(), prec) + "</td>";
      if (SHOW_COMMISSION == 1) res = res + "<td class=\"td1\" style=" + fmt00 + ">" + DoubleToStr(OrderCommission(), 2) + "</td>";
      if (SHOW_SWAP == 1) res = res + "<td class=\"td1\" style=" + fmt00 + ">" + DoubleToStr(OrderSwap(), 2) + "</td>";
      
      comm += OrderCommission();
      swap += OrderSwap();
      val = OrderProfit() + OrderCommission() + OrderSwap();
      if (val > 0) {
        pos_cnt++;
        profit += val;
        max_win = MathMax(max_win, val);
        
        
        cons_los_cnt = 0;
        cons_los_sum = 0;
        cons_win_cnt++;
        cons_win_sum += val;

        if (mc_winners_cnt < cons_win_cnt) {
          mc_winners_cnt = cons_win_cnt;
          mc_winners_sum = cons_win_sum;
        }
        else if (mc_winners_cnt == cons_win_cnt) {
          mc_winners_sum = MathMax(mc_winners_sum, cons_win_sum);
        }
                
        if (mc_profit_sum < cons_win_sum) {
          mc_profit_cnt = cons_win_cnt;
          mc_profit_sum = cons_win_sum;
        }
                
        max_summ_pl = MathMax(max_summ_pl, profit+loss);
        
      } else if (val < 0) {
        neg_cnt++;
        loss += val;        
        max_loss = MathMin(max_loss, val);
        
        cons_win_cnt = 0;
        cons_win_sum = 0;
        cons_los_cnt++;
        cons_los_sum += val;

        if (mc_losers_cnt < cons_los_cnt) {
          mc_losers_cnt = cons_los_cnt;
          mc_losers_sum = cons_los_sum;
        }
        else if (mc_losers_cnt == cons_los_cnt) {
          mc_losers_sum = MathMin(mc_losers_sum, cons_los_sum);
        }

        if (mc_loss_sum > cons_los_sum) {
          mc_loss_cnt = cons_los_cnt;
          mc_loss_sum = cons_los_sum;
        }
                
        min_summ_pl = MathMin(min_summ_pl, profit+loss);
        
        if (max_dd < max_summ_pl-(profit+loss)) {
          max_dd = max_summ_pl-(profit+loss);
          if (depo+max_summ_pl <= 0)
            max_dd2 = 100;
          else
            max_dd2 = 100*max_dd/(depo+max_summ_pl);
        }
      }      
    }

    res = res + "<td class=\"td1\" style=" + fmt00 + ">" + DoubleToStr(OrderProfit(), 2) + "</td>";
    if (SHOW_COMMENT == 1) res = res + "<td>" + OrderComment() + "</td>";
    res = res + "</tr>\n";
    
    num++;
    
    FileWrite(h1, res);
  }
 
  res = "<tr align=right style=\"color:red\">";
  res = res + "<td></td><td></td>";
  if (SHOW_OPENTIME == 1) res = res + "<td></td>";
  res = res + "<td></td><td></td><td></td>";
  if (SHOW_OPENPRICE == 1) res = res + "<td></td>";
  if (SHOW_SL == 1) res = res + "<td></td>";
  if (SHOW_TP == 1) res = res + "<td></td>";
  if (SHOW_CLOSETIME == 1) res = res + "<td></td>";
  if (SHOW_CLOSEPRICE == 1) res = res + "<td></td>";  
  if (SHOW_COMMISSION == 1) res = res + "<td>" + DoubleToStr(comm, 2) + "</td>";
  if (SHOW_SWAP == 1) res = res + "<td>" + DoubleToStr(swap, 2) + "</td>";
  res = res + "<td>" + DoubleToStr(profit+loss-swap-comm, 2) + "</td>";
  res = res + "</tr>\n";
  res = res + "<tr><td>&nbsp;</td></tr>\n";
  
  FileWrite(h1, res);  
 
  t_ind = 0;
  WriteTotal("Deposit/Withdrawal:", DoubleToStr(depo, 2));
  WriteTotal("Summary P/L:", DoubleToStr(profit+loss, 2));
  WriteTotal("Balance:", DoubleToStr(depo+profit+loss, 2));
    
  if (SHOW_STAT_EX == 1) {
    res = "<tr><td>&nbsp;</td></tr>\n";
    FileWrite(h1, res);
  
    t_ind = 0;
    WriteTotal("Winning trades:", "("+pos_cnt+")  " + DoubleToStr(profit, 2));
    WriteTotal("Losing trades:", "("+neg_cnt+")  " + DoubleToStr(loss, 2));
    WriteTotal("Max summary P/L:", DoubleToStr(max_summ_pl, 2));
    WriteTotal("Largest winning trade:", DoubleToStr(max_win, 2));
    WriteTotal("Largest losing trade:", DoubleToStr(max_loss, 2));
    WriteTotal("Max consecutive winners:", mc_winners_cnt +"  ("+ DoubleToStr(mc_winners_sum, 2) +")");
    WriteTotal("Max consecutive losers:", mc_losers_cnt +"  ("+ DoubleToStr(mc_losers_sum, 2) +")");
    WriteTotal("Max consecutive profit:", DoubleToStr(mc_profit_sum, 2) +"  ("+ mc_profit_cnt +")");
    WriteTotal("Max consecutive loss:", DoubleToStr(mc_loss_sum, 2) +"  ("+ mc_loss_cnt +")");

    WriteTotal("Absolute drawdown:", "*");
    WriteTotal("Max drawdown:", DoubleToStr(max_dd, 2) +"  ("+ DoubleToStr(max_dd2, 2) +"%)");

    string str;
    if (loss == 0) str = "*";
    else str = DoubleToStr(MathAbs(profit/loss), 2);
    WriteTotal("Profit factor:", str);
  
    if (loss*pos_cnt == 0) str = "*";
    else str = DoubleToStr(MathAbs((profit*neg_cnt)/(loss*pos_cnt)), 2);
    WriteTotal("Avg. profit factor:", str);

    if (max_dd == 0) str = "*";
    else str = DoubleToStr((profit+loss)/max_dd, 2);
    WriteTotal("Risk factor:", str);
  }
    
  res = "<tr><td>&nbsp;</td></tr>\n";
  FileWrite(h1, res);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void WriteTotal(string text, string val) {
  int cols = 5;
  if (SHOW_OPENTIME == 1) cols++;
  string res = "<tr ";
  if (MathMod(t_ind, 2) == 0) res = res + "bgcolor=#E0E0E0 ";
  res= res + "align=right><td colspan=" + cols + " align=right><b>" + text + "</b></td>";
  
  cols = 1;    
  if (SHOW_OPENPRICE == 1) cols++;
  if (SHOW_SL == 1) cols++;
  if (SHOW_TP == 1) cols++;
  if (SHOW_CLOSETIME == 1) cols++;
  if (SHOW_CLOSEPRICE == 1) cols++;
  if (SHOW_COMMISSION == 1) cols++;
  if (SHOW_SWAP == 1) cols++;
  res = res + "<td colspan=" + cols + " align=right style=\"color:blue\">" + val + "</td>";
  if (SHOW_COMMENT == 1) res = res + "<td></td>";
  res = res + "</tr>\n";
  
  FileWrite(h1, res);
  t_ind++;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void Tail() {
  string res = 
    "</table>\n" + 
    "<div style=\"font: 16pt Times New Roman\"><b>* * *</b></div>\n" +
    "</font></div>\n" +
    "</body></html>\n";

  FileWrite(h1, res);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

string TypeMnem(int type) {
  switch (type) {
    case OP_BUY: return("buy");
    case OP_SELL: return("sell");
    case OP_BUYLIMIT: return("buy limit");
    case OP_SELLLIMIT: return("sell limit");
    case OP_BUYSTOP: return("buy stop");
    case OP_SELLSTOP: return("sell stop");
    default: return("???");
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

string ToLower(string str) {
  int ch;
  int len = StringLen(str);
  for (int j=0; j < len; j++) {
    ch = StringGetChar(str, j);
    if (ch >= 'A' && ch <= 'Z') {
      ch += 'a' - 'A'; 
      str = StringSetChar(str, j, ch);
    }
  }
  
  return (str);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void Sort() {
  if (ArraySize(SortBy) == 0) return(0);

  int res, ticket;
  int size = ArraySize(Tickets);
  for (int i=0; i < size; i++) {
    for (int j=i+1; j < size; j++) {
      res = Compare(Tickets[i], Tickets[j]);
      if (sort_type == DESC) res = -res;
      if (res == -1) {
        ticket = Tickets[i];
        Tickets[i] = Tickets[j];
        Tickets[j] = ticket;        
      }
    }
  } 
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int Compare(int ticket1, int ticket2) {
  int size = ArraySize(SortBy);
  for (int i=0; i < size; i++) {
    sort_type = SortBy2[i];
     
    if (SortBy[i] == BY_TICKET) {
      if (ticket1 < ticket2) return(1);
      if (ticket1 > ticket2) return(-1);
    }
    
    else if (SortBy[i] == BY_OPENTIME) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      string time1 = TimeToStr(OrderOpenTime());
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      string time2 = TimeToStr(OrderOpenTime());
      if (time1 < time2) return(1);
      if (time1 > time2) return(-1);
    }

    else if (SortBy[i] == BY_TYPE) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      int type1 = OrderType();
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      int type2 = OrderType();
      if (type1 < type2) return(1);
      if (type1 > type2) return(-1);
    }

    else if (SortBy[i] == BY_LOTS) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      double lots1 = OrderLots();
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      double lots2 = OrderLots();
      if (lots1 < lots2) return(1);
      if (lots1 > lots2) return(-1);
    }
    
    else if (SortBy[i] == BY_SYMBOL) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      string sym1 = OrderSymbol();
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      string sym2 = OrderSymbol();
      if (sym1 < sym2) return(1);
      if (sym1 > sym2) return(-1);
    }

    else if (SortBy[i] == BY_OPENPRICE) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      double price1 = OrderOpenPrice();
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      double price2 = OrderOpenPrice();
      if (price1 > price2) return(1);
      if (price1 < price2) return(-1);
    }

    else if (SortBy[i] == BY_SL) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      double sl1 = OrderStopLoss();
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      double sl2 = OrderStopLoss();
      if (sl1 > sl2) return(1);
      if (sl1 < sl2) return(-1);
    }

    else if (SortBy[i] == BY_TP) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      double tp1 = OrderTakeProfit();
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      double tp2 = OrderTakeProfit();
      if (tp1 > tp2) return(1);
      if (tp1 < tp2) return(-1);
    }

    else if (SortBy[i] == BY_CLOSETIME) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      time1 = TimeToStr(OrderCloseTime());
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      time2 = TimeToStr(OrderCloseTime());
      if (time1 < time2) return(1);
      if (time1 > time2) return(-1);
    }

    else if (SortBy[i] == BY_CLOSEPRICE) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      price1 = OrderClosePrice();
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      price2 = OrderClosePrice();
      if (price1 > price2) return(1);
      if (price1 < price2) return(-1);
    }
    
    else if (SortBy[i] == BY_COMMISSION) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      double commis1 = OrderCommission();
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      double commis2 = OrderCommission();
      if (commis1 > commis2) return(1);
      if (commis1 < commis2) return(-1);
    }

    else if (SortBy[i] == BY_SWAP) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      double swap1 = OrderSwap();
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      double swap2 = OrderSwap();
      if (swap1 > swap2) return(1);
      if (swap1 < swap2) return(-1);
    }

    else if (SortBy[i] == BY_PROFIT) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      double profit1 = OrderProfit();
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      double profit2 = OrderProfit();
      if (profit1 > profit2) return(1);
      if (profit1 < profit2) return(-1);
    }
    
    else if (SortBy[i] == BY_COMMENT) {
      OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
      string comm1 = OrderComment();
      OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
      string comm2 = OrderComment();
      if (comm1 < comm2) return(1);
      if (comm1 > comm2) return(-1);
    }
  }
    
  return(0);
}