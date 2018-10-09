

/*=======================================================ANOTAÇÕES========================================================


========================================================================================================================*/

static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; 

extern int StopLoss = 10;
extern int TakeProfit = 2;
extern double Lots = 0.02;
extern int MinuteFinish = 50;


string Robo = "EArsima 1.1";
int ticket;
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

 iLots = Lots;       
      

 
   
   

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
                     if(OrderOpenPrice()<OrderClosePrice()) iLots = iLots + 0.01;
                    
                  }//FIM OP_BUY
                  
                  if(OrderType()==OP_SELL)
                  { 
                     if(OrderOpenPrice()>OrderClosePrice()) iLots = iLots + 0.01;
                     
                  }//FIM OP_SELL
                     
               }//FIM MAGICNUMBER 
               
              
                
           }//FIM ORDERSELECT
        }//FIM ORDERHISTORY 
            
          
               
      
//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
 
//=========================MEDIAS MOVEIS      
      double MA9 = iMA(Symbol(),NULL,9,0,MODE_EMA,PRICE_CLOSE,0);
      double MA14 = iMA(Symbol(),NULL,14,0,MODE_EMA,PRICE_CLOSE,0);
      double RSI = iRSI(Symbol(),NULL,14,PRICE_CLOSE,0);
      
    if(OrdersTotal()==0){ ordembuy=0; ordemsell=0; ordembuy2=0; ordemsell2=0;}    
     if(RSI<30 || RSI>70) espera = Time[0] + 30*60;   
                   
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM MAGIC1 E MARTINGALE ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  if(Time[0]>espera)
  {
      if(OrdersTotal()==0)
      { 
         if(MA9>MA14 && Open[0]>MA9 && RSI>50 )    ordembuy = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,Ask+TakeProfit*MyPoint,Robo,MagicNumber,0,Blue);
         if(MA9<MA14 && Open[0]<MA9 && RSI<50 )    ordemsell = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,Bid-TakeProfit*MyPoint,Robo,MagicNumber,0,Red);
      }    
  }     

          

 if(OrderSelect(ordembuy,SELECT_BY_TICKET,MODE_TRADES))
            {  
               if(countbuy>=1)
               {
                  if(OrderType()==OP_BUY)
                  { 
                  
                     if(Ask+StopLoss*MyPoint<OrderOpenPrice()) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);espera = Time[0] + 10*60;
                                                                                  
                  }  
               }
            }
           
            if(OrderSelect(ordemsell,SELECT_BY_TICKET,MODE_TRADES))
            {  
               if(countsell>=1)
               {
                  if(OrderType()==OP_SELL)
                  { 
                 
                     if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera = Time[0] + 10*60;
                                                                                   
                  }  
               }
            }

 





               
  }//FIM ONTICK
 