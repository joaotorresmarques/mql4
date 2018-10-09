/*========DESCRIÇÃO Maringale VIP 1.0====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================

              
========================================================================================================================*/
#property strict
#property  version "1.0"
#property  description "Reverse Trend"

static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; 
extern int StopLoss = 15; 
extern int TakeProfit = 20;
extern double Lots = 0.01;
extern double LotsMult = 0.02;
extern int PipsCandle = 15;

static input string Option2 = "--------Options TrallingStop";
extern bool UseTralling = true;
extern int TrallingStop =20;
extern int TrallingStep = 5;


static input string Option3 = "--------Options Martingale";
extern bool UseMartingale = true;
//extern int CountOrdBeginMartingale = 8;
extern double LotsMultMartingale = 0.03;
extern int MaxOrders = 100;

static input string Option4 = "--------Other Options";
extern int WaitOrder = 8; 


static input string CONTACT = "Joaotorresmarques1@Gmail.com";

string Robo = "Martingale VIP 1.0";
int ticket,take;
double iLots,lote;
datetime espera;
bool STOPTUDOb,STOPTUDO;

int OnInit(){return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
   
//=========================CONTADOR DE ORDENS ABERTAS  
   int count;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
          if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
         
      }
   } 


//=========================LOTES
      if(count>0 && count<7)   iLots = count*LotsMult;
      if(count>=8)  iLots = count*LotsMultMartingale;
      if(count==0) iLots = Lots;
      
//=========================TRALLINGSTOP      
    switch(count) 
   {
      case 0: take = TrallingStop;   break;
      case 1: take = TrallingStop*1; break;
      case 2: take = TrallingStop*1; break;
      case 3: take = TrallingStop*1; break;
      case 4: take = TrallingStop*1; break;
      case 5: take = TrallingStop*1; break;
      case 6: take = TrallingStop+(TrallingStop/2); break;
      case 7: take = TrallingStop+(TrallingStop/2); break;
      case 8: take = TrallingStop+(TrallingStop/2); break;
      case 9: take = TrallingStop+(TrallingStop/2); break;
   } 
   if(count >= 10) take = TrallingStop+(TrallingStop/2)*1;
         
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
                  if(OrderType()==OP_SELL)
                  { 
                     if(OrderOpenPrice()>OrderClosePrice())   STOPTUDO = true; else STOPTUDOb=false; espera = OrderCloseTime()+WaitOrder*60;

                  }//FIM OP_SELL
               
                  if(OrderType()==OP_BUY)
                  {
                     if(OrderOpenPrice()<OrderClosePrice())   STOPTUDOb = true;else STOPTUDOb=false; espera = OrderCloseTime()+WaitOrder*60; 

                  }//FIM OP_BUY
                     
               }//FIM MAGICNUMBER
               }//FIM SELECT
               }//FIM ORDERHISTORY
              
               
           if(UseTralling==true)
           {
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(i,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {  
                     if( STOPTUDO==true || STOPTUDOb==true )  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                  }//FIM MAGIC
               }//FIM SELECT    
           
            }//FIM CONTADOR  
      
      }//fim bool
      
              
                           
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  if(TimeCurrent()>espera)
  {
    if(OrdersTotal()==0)
      { 
         if(UseTralling==false)
         {
        if(Open[0]+PipsCandle*MyPoint<Open[1] ) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,Slippage,Ask-StopLoss*MyPoint,Ask+TakeProfit*MyPoint,Robo,MagicNumber,0,Blue);
        
        if(Open[0]-PipsCandle*MyPoint>Open[1] ) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,Slippage,Bid+StopLoss*MyPoint,Bid-TakeProfit*MyPoint,Robo,MagicNumber,0,Red);
        }
        else if(UseTralling==true)
        {
            if(Open[0]+PipsCandle*MyPoint<Open[1] ) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,Slippage,0,0,Robo,MagicNumber,0,Blue);
        
            if(Open[0]-PipsCandle*MyPoint>Open[1] ) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,Slippage,0,0,Robo,MagicNumber,0,Red);
        }
      }//FIM ORDERSTOTAL
      
    } 


   
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP OU FINISH ORDER+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
  if(UseTralling==true)
  {
    for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber )
         {  
               if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
                  
                  if(SL==0 && Ask+take*MyPoint>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+take*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (OrderStopLoss()<(Ask+TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL+TrallingStep*MyPoint,0,0,clrLightGreen);
                  
  
               }//FIM OP_BUY
               
                if(OrderType()==OP_SELL)
                {
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && Bid-take*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell-take*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (OrderStopLoss()>(Bid-TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell-TrallingStep*MyPoint,0,0,clrLightGreen);

               
               }//FIM OP_SELL
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR
    
       
  }//FIM SE TRALLING FOR TRUE
    
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ENVIO DE ORDEM MARTINGAE SE BOOL FOR TRUE+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
  if(UseMartingale==true)
  {
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
              if(Ask+StopLoss*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,Slippage,0,0,NULL,MagicNumber,0,clrGreenYellow);
               break;                                                                           
            }//FIM OP_BUY 
           }
           
           if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {
             if(OrderType()==OP_SELL)
             {
                if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,Slippage,0,0,NULL,MagicNumber,0,clrGreenYellow);
                break; 
             }//FIM OP_SELL      
         }//FIM MAGICNUMBER 
      }//FIM ORDERSELECT     
   }//FIM CONTADOR  
}
   }
  
   

  }//FIM ONTICK
  

