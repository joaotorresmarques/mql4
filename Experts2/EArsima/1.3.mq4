

/*=======================================================ANOTAÇÕES========================================================

1.3:   Retirar ordembuy e ordemsell. colocar contador!

fazer um contador: Se money=20 lot1.0 , Se money=30 lot2.0(pra ver o grafico lindo.)
========================================================================================================================*/

static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; 

extern int StopLoss = 10;
extern int TakeProfit = 10;
extern double Lots = 0.02;
extern int MinuteFinish = 50;


string Robo = "EArsima 1.3";
int ticket,takeSELL,takeBUY;
double iLots;
datetime espera,newtime;



int ordembuy,ordemsell,ordembuy2,ordemsell2;

int OnInit(){return(INIT_SUCCEEDED);}

void OnTick()
{        
   int count,countbuy,countsell;
   
   for (int trade1=OrdersTotal()-1; trade1>=0; trade1--) 
   {
      if (OrderSelect(trade1,SELECT_BY_POS, MODE_TRADES)) 
      {  
         if(OrderMagicNumber()==MagicNumber)
         {
            if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
            if(OrderType()==OP_BUY) countbuy++;
            if(OrderType()==OP_SELL) countsell++;
         }   
    
     }
   }

   
//=========================CONFIGURAÇÃO DE LOTE    
 switch(count) 
   {
       case 0: iLots = Lots; break;
      case 1: iLots = 0.05; break;
      case 2: iLots = 0.10; break;
      case 3: iLots = 0.20; break;
      case 4: iLots = 0.30; break;
      case 5: iLots = 0.40; break;
      case 6: iLots = 0.50; break;
      case 7: iLots = 1.0; break;
      case 8: iLots = 2.0; break;
      case 9: iLots = 3.0; break;
      case 10: iLots = 3.5; break;
      case 11: iLots = 4.0; break;
      case 12: iLots = 4.5; break;
   }
        
//=========================CONFIGURAÇÃO DE TAKES   
    switch(countsell) 
   {
      
      case 1: takeSELL = 10;       break;
      case 2: takeSELL = TakeProfit;       break;
      case 3: takeSELL = TakeProfit;       break;
      case 4: takeSELL = TakeProfit+2;     break;
      case 5: takeSELL = TakeProfit+2;     break;
      case 6: takeSELL = TakeProfit+5;     break;
      case 7: takeSELL = TakeProfit+7;     break;
      case 8: takeSELL = TakeProfit+7;     break;
      case 9: takeSELL = TakeProfit+7;     break;
   } 
   if(count >= 10) takeSELL = TakeProfit+10;
   
    switch(countbuy) 
   {
      
      case 1: takeBUY = 10;        break;
      case 2: takeBUY = TakeProfit;        break;
      case 3: takeBUY = TakeProfit;        break;
      case 4: takeBUY = TakeProfit+2;      break;
      case 5: takeBUY = TakeProfit+2;      break;
      case 6: takeBUY = TakeProfit+5;      break;
      case 7: takeBUY = TakeProfit+7;      break;
      case 8: takeBUY = TakeProfit+7;      break;
      case 9: takeBUY = TakeProfit+7;      break; 
   } 
   if(count >= 10) takeBUY = TakeProfit+10;         

//=========================EXCLUSAO DE TAKE DE ORDEM -1
 
            for(int i3=OrdersTotal()-2; i3>=0; i3--)   
            {
               if(OrderSelect(i3,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {  
                     if(OrderType()==OP_BUY)    ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),0,0,clrNONE); break;
                     if(OrderType()==OP_SELL )  ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),0,0,clrNONE); break;
                      
                  
                  }//FIM ORDERMAGIC
                  
                 
  
                }//FIM SELECT 
           
            }//FIM CONTADOR    
   

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
                     if(OrderOpenPrice()<OrderClosePrice()) bool STOPTUDOb = true; 
                    
                  }//FIM OP_BUY
                  
                  if(OrderType()==OP_SELL)
                  { 
                     if(OrderOpenPrice()>OrderClosePrice()) bool STOPTUDO2 = true;
                     
                  }//FIM OP_SELL
                     
               }//FIM MAGICNUMBER 
               
              
                
           }//FIM ORDERSELECT
        }//FIM ORDERHISTORY 
            
          
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(i,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {  
                     if(OrderType()==OP_BUY)
                     {
                        if(STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera = Time[0] + 50*60;
                     }   
                     
                     if(OrderType()==OP_SELL )
                     {
                     
                      if(STOPTUDO2==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera = Time[0] + 50*60;
                      
                     }
                  
                  }//FIM ORDERMAGIC
                  
                 
  
                }//FIM SELECT 
           
            }//FIM CONTADOR  
            if(OrderSelect(ordemsell,SELECT_BY_TICKET,MODE_TRADES)) newtime = OrderOpenTime();
            if(OrderSelect(ordembuy,SELECT_BY_TICKET,MODE_TRADES))  newtime = OrderOpenTime();        
      
//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
 
//=========================MEDIAS MOVEIS      
      double MA9 = iMA(Symbol(),NULL,9,0,MODE_EMA,PRICE_CLOSE,0);
      double MA14 = iMA(Symbol(),NULL,14,0,MODE_EMA,PRICE_CLOSE,0);
      double MA50 = iMA(Symbol(),NULL,50,0,MODE_EMA,PRICE_CLOSE,0);
      double RSI = iRSI(Symbol(),NULL,14,PRICE_CLOSE,0);
      
    if(OrdersTotal()==0){ ordembuy=0; ordemsell=0; ordembuy2=0; ordemsell2=0;}    
     if(RSI<30 || RSI>70) espera = Time[0] + 30*60;   
                   
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM MAGIC1 E MARTINGALE ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  if(Time[0]>espera)
  {
      if(OrdersTotal()==0)
      { 
         if((MA9>MA14) && MA9>MA50 && MA14>MA50 && Open[0]>MA9 && RSI>54 )    ordembuy = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,Ask+TakeProfit*MyPoint,Robo,MagicNumber,0,Blue);
         if((MA9<MA14) && MA9<MA50 && MA14<MA50 && Open[0]<MA9 && RSI<46 )    ordemsell = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,Bid-TakeProfit*MyPoint,Robo,MagicNumber,0,Red);
      }    
  }     

            if(OrderSelect(ordembuy,SELECT_BY_TICKET,MODE_TRADES))
            {  
               if(countbuy>=1)
               {
                  if(OrderType()==OP_BUY)
                  { 
                  if(newtime<Time[0])
                     {
                     if(Ask+StopLoss*MyPoint<OrderOpenPrice()) ordembuy = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,Ask+takeBUY*MyPoint,Robo,MagicNumber,0,clrGreenYellow);
                     }                                                             
                  }  
               }
            }
           
            if(OrderSelect(ordemsell,SELECT_BY_TICKET,MODE_TRADES))
            {  
               if(countsell>=1)
               {
                  if(OrderType()==OP_SELL)
                  { 
                  if(newtime<Time[0])
                     {
                     if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ordemsell = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,Bid-takeSELL*MyPoint,Robo,MagicNumber,0,clrGreenYellow);
                     }                                                              
                  }  
               }
            }


 





               
  }//FIM ONTICK
 