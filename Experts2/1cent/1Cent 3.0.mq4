/*========DESCRIÇÃO 3.0====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================
COM MARTINGALE!

   .QND TEM MAIS DE 7ORDENS AUMENTAR O TAKE
   .GATILHO DE ENTRADA 1ºORDEM
   .ARRUMAR O MENU INPUT
   
   verificcar porque nao entra BUYSTOP em 05/02. so entra SHELLSTOP.
   verificar que quando SHELL da take vem outro shellstop. é bom colocar um intervalo.
   
   baixar loira marrenta*
   
   
========================================================================================================================*/

string Robo = "1.0";
static input string Amarelo = "oii";
extern int Slippage = 3;
extern int MagicNumber = 9090909;
extern int StopLoss = 5;
extern int TakeProfit =10;
extern int Tralling = 4;
extern int TakeProfitMartingale = 15;
extern int TrallingMartingale = 5;

extern int PipsCandle=20;
extern int DistancePips=2;
extern int MinuteFinish = 9;

extern double LotsMult = 0.02;
extern double Lots = 0.01;


int ticket;
double iLots;



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

//=========================LOTES
      
     /* if(NumOfTrades<4) Lots=0.01;
      if(NumOfTrades>4) Lots=0.09;*/
      iLots = Lots+(count*LotsMult);  
         

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
               if(OrderSelect(v,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {
                      if( STOPTUDO==true || STOPTUDOb==true )  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                  }//FIM ORDERMAGIC 
                }//FIM SELECT 
           
            }//FIM CONTADOR  
     
              
                           
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    if(OrdersTotal()<=0)
    {
     if(countbuy==0 && countbuystop==0)
   {
      if(High[0]-Low[0]>PipsCandle*MyPoint)
      {
         ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots, Low[0]+DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue); 
      }
   }//FIM BUYSTOP

   if(countsell==0 && countsellstop==0)
   {
      if(High[0]-Low[0]>PipsCandle*MyPoint)
      {
         ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,High[0]-DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Red);   
      }
   }//FIM SELLSTOP
    
      
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
    
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {  
            if(count==1)
            {
               if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
                  
                  if(SL==0 && Ask+TakeProfit*MyPoint>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+TakeProfit*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (OrderStopLoss()<(Ask+Tralling*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL+Tralling*MyPoint,0,0,clrLightGreen);
                  
  
               }//FIM OP_BUY
               
                if(OrderType()==OP_SELL)
                {
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && Bid-TakeProfit*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell-TakeProfit*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (OrderStopLoss()>(Bid-Tralling*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell-Tralling*MyPoint,0,0,clrLightGreen);

               
               }//FIM OP_SELL
           }//Fim trallingstop 1ORDEM.
           
           if(count>1)
           {
               if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy2 = OrderOpenPrice();
                  double SL2 = OrderStopLoss();
                  
                  if(SL2==0 && Ask+TakeProfitMartingale*MyPoint>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy2+TakeProfitMartingale*MyPoint,0,0,clrLightGreen);
                  
                  if(SL2>0 && (OrderStopLoss()<(Ask+TrallingMartingale*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL2+TrallingMartingale*MyPoint,0,0,clrLightGreen);
                  
  
               }//FIM OP_BUY
               
                if(OrderType()==OP_SELL)
                {
                  double stnewpricesell2 = OrderOpenPrice();
                  double SLsell2 = OrderStopLoss();
               
                  if(SLsell2==0 && Bid-TakeProfitMartingale*MyPoint<stnewpricesell2) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell2-TakeProfitMartingale*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell2>0 && (OrderStopLoss()>(Bid-TrallingMartingale*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell2-TrallingMartingale*MyPoint,0,0,clrLightGreen);

               
               }//FIM OP_SELL
           }//Fim trallingstop 1ORDEM.
               
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR  
    
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ENVIO DE ORDEM MARTINGAE++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
          
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
   

  }//FIM ONTICK
  

