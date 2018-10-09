/*========DESCRIÇÃO 1.0====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================

  FALTA: ARRUMAR O LOT.
         CONTAGEM DE DINHEIRO P/ AUMENTAR LOTE.
========================================================================================================================*/

string Robo = "1.0";
static input string Amarelo = "oii";

extern int Slippage = 3;
extern int MagicNumber = 121212;

extern int TAKE = 8;
extern int Tralling = 0;
extern int STOP = 10;
extern double Lots = 0.01;
extern double LotsMult = 0.02;
extern int TimeWait = 1000;



double Spread=MarketInfo(Symbol(),MODE_SPREAD);
int ticket,NumOfTrades,modify;
datetime tempo;
double iLots,ultimolot,balanco;

int OnInit()
{
return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;               
      
//=========================CONTADORES
      NumOfTrades = CountTrades();
      
//=========================LOTES
      
     /* if(NumOfTrades<4) Lots=0.01;
      if(NumOfTrades>4) Lots=0.09;*/
      iLots = Lots+(NumOfTrades*LotsMult);  
     
              
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++FECHAR TODAS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
   
      
         static int closedOrders=0;
         if(OrdersHistoryTotal()!=closedOrders)
         {
            closedOrders=OrdersHistoryTotal();
            int hstTotal = OrdersHistoryTotal(); 
        
            if(OrderSelect(hstTotal-1,SELECT_BY_POS,MODE_HISTORY))
            {
               if(OrderMagicNumber()==MagicNumber)
               {  
                      
                  tempo = OrderCloseTime();
                  if(OrderType()==OP_SELL)
                  { 
                     if(OrderOpenPrice()>OrderClosePrice())  bool STOPTUDO = true;

                  }//FIM OP_SELL
               
                  if(OrderType()==OP_BUY)
                  {
                     if(OrderOpenPrice()<OrderClosePrice())  bool STOPTUDOb = true;

                  }//FIM OP_BUY
                     
               }//FIM MAGICNUMBER
               
              
           }//FIM ORDERSELECT
           
           
   
        }//FIM ORDERHISTORY 
            
            int v, totalv=OrdersTotal();
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(i,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {
                      if( STOPTUDO==true || STOPTUDOb==true )  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                  } 
                } 
           
            }//FIM CONTADOR  
 

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    if(Time[0]>=tempo+TimeWait)
   {
      if(OrdersTotal()==0)
      { 
        if(Open[0]+15*MyPoint<Open[1] ) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,0,Robo,MagicNumber,0,Blue);
        
        if(Open[0]-15*MyPoint>Open[1] ) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,0,Robo,MagicNumber,0,Red);
        
      }//FIM ORDERSTOTAL
    }//FIM TIME

    
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++SOBRE ENVIO MAGIC1++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
          
   for (int trade=OrdersTotal()-1; trade>=0; trade--) 
   {
      if (OrderSelect(trade,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {

            if(OrderType()==OP_SELL)
            {
                if(Bid-STOP*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,0,NULL,MagicNumber,0,clrGreenYellow);
                break; 
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
              if(Ask+STOP*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,0,NULL,MagicNumber,0,clrGreenYellow);
               break;                                                                           
           }//FIM OP_BUY
           
           
            
                 
         }//FIM MAGICNUMBER 
      }//FIM ORDERSELECT     
   }//FIM CONTADOR

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++Tralling Stop++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
   {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {
            if(NumOfTrades>=1 && NumOfTrades<=3)
            {
               if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
                  
                  if(SL==0 && Ask-10*MyPoint>stnewpricebuy) modify = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+8*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && Ask-8*MyPoint>SL)   modify = OrderModify(OrderTicket(),OrderOpenPrice(),SL+5*MyPoint,0,0,clrLightGreen);
                  
               }//FIM OP_BUY
               
                if(OrderType()==OP_SELL)
                  {
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && Bid+10*MyPoint<stnewpricesell) modify = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell-8*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && Bid+8*MyPoint<SLsell)   modify = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell-5*MyPoint,0,0,clrLightGreen);
               
               }//FIM OP_SELL
               
             }//FIM NUMOFTRADERS
             
              if(NumOfTrades>3 )
            {
               if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy2 = OrderOpenPrice();
                  double SL2 = OrderStopLoss();
                  
                  if(SL2==0 && Ask-25*MyPoint>stnewpricebuy2) modify = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy2+20*MyPoint,0,0,clrLightGreen);
                  
                  if(SL2>0 && Ask-8*MyPoint>SL2)   modify = OrderModify(OrderTicket(),OrderOpenPrice(),SL2+5*MyPoint,0,0,clrLightGreen);
                  
               }//FIM OP_BUY
               
                if(OrderType()==OP_SELL)
                  {
                  double stnewpricesell2 = OrderOpenPrice();
                  double SLsell2 = OrderStopLoss();
               
                  if(SLsell2==0 && Bid+25*MyPoint<stnewpricesell2) modify = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell2-20*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell2>0 && Bid+8*MyPoint<SLsell2)   modify = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell2-5*MyPoint,0,0,clrLightGreen);
               
               }//FIM OP_SELL
               
             }//FIM NUMOFTRADERS
               
               
               
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR   
                  

  }//FIM ONTICK
  


//=========================CONTADOR DE ORDEM MAGICNUMBER
  
   int CountTrades() {
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
        
   }
   return (count);
}


