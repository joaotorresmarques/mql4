//+------------------------------------------------------------------+
//|                     GY 1M Bollinger Bands Scalping System EA.mq4 |
//|                              Copyright © 2008, TradingSytemForex |
//|                                http://www.tradingsystemforex.com |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2008, TradingSytemForex"
#property link "http://www.tradingsystemforex.com"



extern string CBB="---------------- Central BBands";
extern int Period1=50;
extern int Deviations1=4;
extern string RBB="---------------- Red BBands";
extern int Period2=50;
extern int Deviations2=2;
extern string OBB="---------------- Orange BBands";
extern int Period3=50;
extern int Deviations3=3;
extern string VOL="---------------- Volumes";
extern bool UseMinimumVolumes=false; //the ea will trade only if the volumes average of the two previous bar are higher than minimum volumes
extern int MinimumVolumes=20;
extern string LM="---------------- Lot Management";
extern double Lots=0.1;
extern bool MM=false; //money management
extern double Risk=10; //risk in percentage
extern bool Martingale=false; //martingale
extern double Multiplier=1.5; //multiplier
extern double MinProfit=0; //minimum profit to apply the martingale
extern string TSTB="---------------- TP SL TS BE";
extern bool RealSL_Enabled=false;
extern int RealSL=10; //stop loss under 15 pîps
extern bool RealTP_Enabled=false;
extern int RealTP=10; //take profit under 10 pîps
extern int SL=0; //stop loss
extern int TP=0; //take profit
extern int TS=0; //trailing stop
int TS_Step=1; //trailing step
extern int BE=0; //breakeven
extern string EXT="---------------- Extras";
extern bool Reverse=false;
extern bool Add_Positions=false; //positions cumulated
extern int MaxOrders=100; //maximum number of orders
extern bool TimeFilter=false; //time filter
extern int StartHour=8;
extern int EndHour=21;
extern int Magic=0;

int Slip=3;static int TL=0;double Balance=0.0;int err=0;int TK;

// expert start function
int OnTick(){
int j=0,limit=1;
double BV=0,SV=0;BV=0;SV=0;
double BB1,BB2,BB3,BB4,BB5,BB6,BB7,BB8,BB9,BB10,VOL1,VOL2;
if(CntO(OP_BUY,Magic)>0)   TL=1;
if(CntO(OP_SELL,Magic)>0)TL=-1;

for(int i=1;i<=limit;i++){

BB1=iBands(NULL,0,Period3,Deviations3,0,PRICE_CLOSE,MODE_UPPER,i+1);
BB2=iBands(NULL,0,Period2,Deviations2,0,PRICE_CLOSE,MODE_UPPER,i+1);
BB3=iBands(NULL,0,Period1,Deviations1,0,PRICE_CLOSE,0,i+1);
BB4=iBands(NULL,0,Period2,Deviations2,0,PRICE_CLOSE,MODE_LOWER,i+1);
BB5=iBands(NULL,0,Period3,Deviations3,0,PRICE_CLOSE,MODE_LOWER,i+1);

BB6=iBands(NULL,0,Period3,Deviations3,0,PRICE_CLOSE,MODE_UPPER,i);
BB7=iBands(NULL,0,Period2,Deviations2,0,PRICE_CLOSE,MODE_UPPER,i);
BB8=iBands(NULL,0,Period1,Deviations1,0,PRICE_CLOSE,0,i);
BB9=iBands(NULL,0,Period2,Deviations2,0,PRICE_CLOSE,MODE_LOWER,i);
BB10=iBands(NULL,0,Period3,Deviations3,0,PRICE_CLOSE,MODE_LOWER,i);

VOL1=iVolume(NULL,0,i+2);
VOL2=iVolume(NULL,0,i+1);

string volok="false";
if((UseMinimumVolumes==true&&((VOL1+VOL2)/2) >  MinimumVolumes)   || UseMinimumVolumes==false)  volok="true";

if(Open[i+1]>((BB4+BB5)/2)&&Bid<((BB9+BB10)/2)&&volok=="true"){if(Reverse)SV=1;else BV=1;break;}
if(Open[i+1]<((BB1+BB2)/2)&& Ask>((BB6+BB7)/2)&&volok=="true"){if(Reverse)BV=1;else SV=1;break;}}

// expert money management
if(MM){if(Risk<0.1||Risk>100){Comment("Invalid Risk Value.");return(0);}
else{Lots=MathFloor((AccountFreeMargin()*AccountLeverage()*Risk*Point*100)/(Ask*MarketInfo(Symbol(),MODE_LOTSIZE)*MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT);}}
if(MM==false){Lots=Lots;}
if(Balance!=0.0&&Martingale==True){if(Balance>AccountBalance())Lots=Multiplier*Lots;else if((Balance+MinProfit)<AccountBalance())Lots=Lots/Multiplier;else if((Balance+MinProfit)>=AccountBalance()&&Balance<=AccountBalance())Lots=Lots;}Balance=AccountBalance();

// expert init positions
int cnt=0,OP=0,OS=0,OB=0,CS=0,CB=0;OP=0;for(cnt=0;cnt<OrdersTotal();cnt++){OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
if((OrderType()==OP_SELL||OrderType()==OP_BUY)&&OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0))OP=OP+1;}
if(OP>=1){OS=0; OB=0;}OB=0;OS=0;CB=0;CS=0;

// expert conditions to open position
if(SV>0){OS=1;OB=0;}if(BV>0){OB=1;OS=0;}
if(TimeFilter){if(!(Hour()>=StartHour && Hour()<=EndHour)){Comment("Non-Trading Hours!");return(0);}}

// expert conditions to close position
if(Open[i+1]>BB3&&Bid<BB8){if(Reverse)CB=1;else CS=1;}
if(Open[i+1]<BB3&&Ask>BB8){if(Reverse)CS=1;else CB=1;}
if((SV>0)||(RealSL_Enabled&&(OrderOpenPrice()-Bid)/Point>=RealSL)||(RealTP_Enabled&&(Ask-OrderOpenPrice())/Point>=RealTP)){CB=1;}
if((BV>0)||(RealSL_Enabled&&(Ask-OrderOpenPrice())/Point>=RealSL)||(RealTP_Enabled&&(OrderOpenPrice()-Bid)/Point>=RealTP)){CS=1;}
for(cnt=0;cnt<OrdersTotal();cnt++){OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
if(OrderType()==OP_BUY&&OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0)){if(CB==1){OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Red);return(0);}}
if(OrderType()==OP_SELL&&OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0)){
if(CS==1){OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);return(0);}}}double SLI=0,TPI=0;int TK=0;

// expert open position value
if((AddP()&&Add_Positions&&OP<=MaxOrders)||(OP==0&&!Add_Positions)){
if(OS==1){if(TP==0)TPI=0;else TPI=Bid-TP*Point;if(SL==0)SLI=0;else SLI=Bid+SL*Point;TK=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,SLI,TPI,0,Magic,0,Red);OS=0;return(0);}	
if(OB==1){if(TP==0)TPI=0;else TPI=Ask+TP*Point;if(SL==0)SLI=0;else SLI=Ask-SL*Point;TK=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,SLI,TPI,0,Magic,0,Lime);OB=0; return(0);}}
for(j=0;j<OrdersTotal();j++){if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)){if(OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0)){TrP();}}}return(0);}

// expert number of orders
int CntO(int Type,int Magic){int _CntO;_CntO=0;
for(int j=0;j<OrdersTotal();j++){OrderSelect(j,SELECT_BY_POS,MODE_TRADES);if(OrderSymbol()==Symbol()){if((OrderType()==Type&&(OrderMagicNumber()==Magic)||Magic==0))_CntO++;}}return(_CntO);}

//expert breakeven
void TrP(){double pb,pa,pp;pp=MarketInfo(OrderSymbol(),MODE_POINT);if(OrderType()==OP_BUY){pb=MarketInfo(OrderSymbol(),MODE_BID);
if(BE>0){if((pb-OrderOpenPrice())>BE*pp){if((OrderStopLoss()-OrderOpenPrice())<0){ModSL(OrderOpenPrice()+0*pp);}}}

// expert trailing stop
if(TS>0){if((pb-OrderOpenPrice())>TS*pp){if(OrderStopLoss()<pb-(TS+TS_Step-1)*pp){ModSL(pb-TS*pp);return;}}}}
if(OrderType()==OP_SELL){pa=MarketInfo(OrderSymbol(),MODE_ASK);if(BE>0){if((OrderOpenPrice()-pa)>BE*pp){if((OrderOpenPrice()-OrderStopLoss())<0){ModSL(OrderOpenPrice()-0*pp);}}}
if(TS>0){if(OrderOpenPrice()-pa>TS*pp){if(OrderStopLoss()>pa+(TS+TS_Step-1)*pp||OrderStopLoss()==0){ModSL(pa+TS*pp);return;}}}}}

//expert stoploss
void ModSL(double ldSL){bool fm;fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldSL,OrderTakeProfit(),0,CLR_NONE);}

//expert add positions function
bool AddP(){int _num=0; int _ot=0;
for (int j=0;j<OrdersTotal();j++){if(OrderSelect(j,SELECT_BY_POS)==true && OrderSymbol()==Symbol()&&OrderType()<3&&((OrderMagicNumber()==Magic)||Magic==0)){	
_num++;if(OrderOpenTime()>_ot) _ot=OrderOpenTime();}}if(_num==0) return(true);if(_num>0 && ((Time[0]-_ot))>0) return(true);else return(false);

if(TK<0){if (GetLastError()==134){err=1;Print("NOT ENOGUGHT MONEY!!");}return (-1);}}


