/*========DESCRIÇÃO 3.0====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================
COM MARTINGALE!

O gatilho não ta respeitando a programação! más ta dando lucro em 4meses no USDJPY que eu testei. bem, vou tentar melhorar na versão 1.2.
más gostei do jeito que ta. pode melhorar! =)
   
========================================================================================================================*/

static input string Option1 = "oii";
extern int Slippage = 3;
extern int MagicNumber = 9090909;
extern int StopLoss = 10;
extern int TakeProfit =7;
extern int Tralling = 5;
extern int TakeProfitMartingale = 15;
extern int TrallingMartingale = 10;

extern int PipsCandle=20;
extern int DistancePips=2;
extern int MinuteFinish = 5;

extern double LotsMult = 0.02;
extern double Lots = 0.01;
extern int MaxOrders = 100;

string Robo = "1.0";
int ticket,takeBUY,takeSELL;
double iLots,lote;
datetime espera;

bool STOPTUDO,STOPTUDOb;




int OnInit()
{
return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
      
                
      
//=========================CONTADOR DE ORDENS ABERTAS  
   int count,countsellstop,countbuystop,countsell,countbuy;
   
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
         if (OrderType() == OP_SELLSTOP) countsellstop++; 
         if (OrderType() == OP_BUYSTOP) countbuystop++; 
         if (OrderType() == OP_SELL) countsell++; 
         if (OrderType() == OP_BUY) countbuy++;    
   } 

if(countsell==0) STOPTUDO=false;
if(countbuy==0) STOPTUDOb=false;
//=========================LOTES
      
     iLots = count*LotsMult;

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
                     if(OrderOpenPrice()>OrderClosePrice())   STOPTUDO = true; //espera = OrderCloseTime()+MinuteFinish*60;

                  }//FIM OP_SELL
               
                  if(OrderType()==OP_BUY)
                  {
                     if(OrderOpenPrice()<OrderClosePrice())  STOPTUDOb = true; //espera = OrderCloseTime()+MinuteFinish*60;

                  }//FIM OP_BUY
                     
               }//FIM MAGICNUMBER 
           }//FIM ORDERSELECT
        }//FIM ORDERHISTORY 
            
            int v, totalv=OrdersTotal();
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(v,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {  if(OrderType()==OP_SELL)
                     {
                      if(STOPTUDO==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                     }
                     
                     if(OrderType()==OP_BUY)
                     {
                        if(STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                     }   
                  
                  }//FIM ORDERMAGIC 
                }//FIM SELECT 
           
            }//FIM CONTADOR  
     
              
                           
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    if(countbuy==0 && countbuystop==0)
    {
      if(Bid+PipsCandle*MyPoint<Open[1] && Ask-8*MyPoint>Open[0] ) //pipscandle/2
      {
         ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots, High[0]+DistancePips*MyPoint,Slippage,0,0,"buy",MagicNumber,0,Blue); 
      }
      
      if(Ask-PipsCandle*MyPoint>Open[1] && Ask-8*MyPoint>Open[0])
      {
         ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots, High[0]+DistancePips*MyPoint,Slippage,0,0,"buy",MagicNumber,0,Blue); 
      }   
   
    }//FIM BUYSTOP
    
    if(countsell==0 && countsellstop==0)
    {
      if(Bid+PipsCandle*MyPoint<Open[1] && Bid-8*MyPoint<Open[0])
      {
          ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Open[0]-DistancePips*MyPoint,Slippage,0,0,"shell",MagicNumber,0,Red);
      }
      if(Ask-PipsCandle*MyPoint>Open[1] && Bid-8*MyPoint<Open[0])
      {
          ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Open[0]-DistancePips*MyPoint,Slippage,0,0,"shell",MagicNumber,0,Red);
      }        
    }   

//++++++++++++++++++++++++++++++++++++++++++++++++++ENCERRAR ORDENS PENDENTES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    for (int trade7=OrdersTotal()-1; trade7>=0; trade7--) 
   {
      if (OrderSelect(trade7,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {    
            if(OrderType()==OP_BUYSTOP)
            {   
               if(OrderOpenTime()<Time[0]-MinuteFinish*60) ticket = OrderDelete(OrderTicket(),Green);  /*OrderOpenTime()<+MinuteEnd*60==TimeCurrent()*/
            }//FIM OP_BUYSTOP
            
            if(OrderType()==OP_SELLSTOP)
            {  
               if(OrderOpenTime()<Time[0]-MinuteFinish*60) ticket = OrderDelete(OrderTicket(),Green); 
            }//FIM OP_SELLSTOP
             
         }//FIM MAGIC
      }//FIM ORDERSELECT
    }//FIM CONTADOR
    
  
//=========================CONFIGURAÇÃO DE TAKES   
    switch(countsell) 
   {
      case 1: takeSELL = TakeProfit*1; break;
      case 2: takeSELL = TakeProfit*1; break;
      case 3: takeSELL = TakeProfitMartingale*2; break;
      case 4: takeSELL = TakeProfitMartingale*2; break;
      case 5: takeSELL = TakeProfitMartingale*2; break;
      case 6: takeSELL = TakeProfitMartingale*2; break;
      case 7: takeSELL = TakeProfitMartingale*2; break;
      case 8: takeSELL = TakeProfitMartingale*3; break;
      case 9: takeSELL = TakeProfitMartingale*3; break;
      
      case 0: takeSELL = TakeProfit; break;
   }     
   
   if(countsell >= 10) takeSELL = TakeProfitMartingale*7; 
   
    switch(countbuy) 
   {
      case 1: takeBUY = TakeProfit*1; break;
      case 2: takeBUY = TakeProfit*1; break;
      case 3: takeBUY = TakeProfitMartingale*2; break;
      case 4: takeBUY = TakeProfitMartingale*2; break;
      case 5: takeBUY = TakeProfitMartingale*2; break;
      case 6: takeBUY = TakeProfitMartingale*2; break;
      case 7: takeBUY = TakeProfitMartingale*2; break;
      case 8: takeBUY = TakeProfitMartingale*3; break;
      case 9: takeBUY = TakeProfitMartingale*3; break;
      
      case 0: takeBUY = TakeProfit; break;
   } 
   if(countsell >= 10) takeBUY = TakeProfitMartingale*7;
   
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {  
               if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
                  
                  if(SL==0 && Ask+takeBUY*MyPoint>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+takeBUY*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (OrderStopLoss()<(Ask+TrallingMartingale*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL+TrallingMartingale*MyPoint,0,0,clrLightGreen);
                  
  
               }//FIM OP_BUY
               
                if(OrderType()==OP_SELL)
                {
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && Bid-takeSELL*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell-takeSELL*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (OrderStopLoss()>(Bid-TrallingMartingale*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell-TrallingMartingale*MyPoint,0,0,clrLightGreen);

               
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
             if(OrderType()==OP_SELL)
             {
                if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,0,NULL,MagicNumber,0,clrGreenYellow);
                break; 
             }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
              if(Ask+StopLoss*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,0,NULL,MagicNumber,0,clrGreenYellow);
               break;                                                                           
            }//FIM OP_BUY 
                 
         }//FIM MAGICNUMBER 
      }//FIM ORDERSELECT     
   }//FIM CONTADOR  
}
   
  
   

  }//FIM ONTICK
  

