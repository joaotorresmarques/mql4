/*========DESCRIÇÃO 3.0====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================
tralling stop n ta funcionando.
   
========================================================================================================================*/

static input string Option1 = "Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; //BUY
extern int StopLoss = 10;
extern int TakeProfit =10;
extern int Tralling = 5;
extern double Lots = 0.01;
extern double LotsMult = 0.02;

static input string Option2 = "Options Martingale";
extern int TakeProfitMartingale = 15;
extern double LotsMultMartingale = 0.06;

static input string Option3 = "Other Options";
extern int PipsCandle=10;
extern int DistancePips=5;
extern int MinuteFinish = 6;
extern int MaxOrders = 100;

static input string HELP = "Help? Joaotorresmarques1@Gmail.com";

string Robo = "1.0";
int ticket,take;
double iLots,lote;
datetime espera;





int OnInit()
{
return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
      
      double MA = iMA(Symbol(),NULL,11,0,MODE_SMA,PRICE_CLOSE,0);
   
//=========================CONTADOR DE ORDENS ABERTAS  
   int count;
   
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber){
      
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;  
         }
        
   } 


//=========================LOTES

      if(count<=5)   iLots = count*LotsMult;
     if(count>5)  iLots = count*LotsMultMartingale;
     
//++++++++++++++++++++++++++++++++++++++++++++++++++++ENCERRAR TODAS AS ORDENS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

         static int closedOrders=0;
         if(OrdersHistoryTotal()!=closedOrders)
         {
            closedOrders=OrdersHistoryTotal();
            int hstTotal = OrdersHistoryTotal(); 
        
            if(OrderSelect(hstTotal-1,SELECT_BY_POS,MODE_HISTORY))
            {
               if(OrderMagicNumber()==MagicNumber)
               {  

                  if(OrderType()==OP_BUY)
                  {
                     if(OrderOpenPrice()<OrderClosePrice())  bool STOPTUDOb = true; espera = OrderCloseTime()+MinuteFinish*60;

                  }//FIM OP_BUY
                  
                  if(OrderType()==OP_SELL)
                  { 
                     if(OrderOpenPrice()>OrderClosePrice())   bool STOPTUDO2 = true; espera = OrderCloseTime()+MinuteFinish*60;

                  }//FIM OP_SELL
                     
               }//FIM MAGICNUMBER 
               }
               }
               
               
            
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(i,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {  
                     
                     if(OrderType()==OP_BUY)
                     {
                        if(STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                     }   
                     
                      if(OrderType()==OP_SELL )
                     {
                      if(STOPTUDO2==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                     }
                  
                  }//FIM ORDERMAGIC 
                  
                  
                }
                }
     
              
                           
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  if(TimeCurrent()>espera)
  {
    if(OrdersTotal()==0) 
      {
         if(Open[0]>MA) ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,0,0,0,NULL,MagicNumber,0,Red);
         if(Open[0]<MA) ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,0,0,0,NULL,MagicNumber,0,Blue);
      }    
 
    } 


  
//=========================CONFIGURAÇÃO DE TAKES   
    switch(count) 
   {
      case 1: take = TakeProfit*1; break;
      case 2: take = TakeProfit*1; break;
      case 3: take = TakeProfit*1; break;
      case 4: take = TakeProfit*1; break;
      case 5: take = TakeProfit*2; break;
      case 6: take = TakeProfitMartingale*1; break;
      case 7: take = TakeProfitMartingale*1; break;
      case 8: take = TakeProfitMartingale*1; break;
      case 9: take = TakeProfitMartingale*1; break;
      
      case 0: take = TakeProfit; break;
   }     
   if(count >= 10) take = TakeProfitMartingale+count*2;
  
   
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
     for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MagicNumber ))
         {  
               if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
                  
                  if(SL==0 && Ask+take*MyPoint>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+take*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (OrderStopLoss()<(Ask+Tralling*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL+Tralling*MyPoint,0,0,clrLightGreen);
                  
  
               }//FIM OP_BUY
               
                if(OrderType()==OP_SELL)
                {
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && Bid-take*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell-take*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (OrderStopLoss()>(Bid-Tralling*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell-Tralling*MyPoint,0,0,clrLightGreen);

               
               }//FIM OP_SELL
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR  
    
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ENVIO DE ORDEM MARTINGAE++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
   if(count<MaxOrders)
   {       
   for (int trade1=OrdersTotal()-1; trade1>=0; trade1--) 
   {
      if (OrderSelect(trade1,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {
                       
            if(OrderType()==OP_BUY)
            {
              if(Ask+StopLoss*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,0,NULL,MagicNumber,0,clrGreenYellow);
               break;                                                                           
            }//FIM OP_BUY 
           
           
            if(OrderType()==OP_SELL)
             {
                if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,0,NULL,MagicNumber,0,clrGreenYellow);
                break; 
             }//FIM OP_SELL  
           
           
         
         }//FIM MAGICNUMBER 
      }//FIM ORDERSELECT     
   }//FIM CONTADOR  
}
   
  
   

  }//FIM ONTICK
  

