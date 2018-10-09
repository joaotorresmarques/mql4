

/*=======================================================ANOTA��ES========================================================
HEDGE.
========================================================================================================================*/

static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; 

extern int StopLoss = 60;
extern int TakeProfit = 30;
extern int Distancia = 30;

extern double Lots = 0.01;
extern int MinuteFinish = 50;

static input string Option2 = "--------Options TrallingStop";
extern int TrallingStop =10;
extern int TrallingStep = 3;


string Robo = "EArsima";
int ticket,takeBUY,takeSELL,takeBUY2,takeSELL2;
double iLots;
datetime espera;




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

   
//=========================CONFIGURA��O DE LOTE    
 switch(count) 
   {
      case 0: iLots = Lots; break;
      case 1: iLots = 0.03; break;
      case 2: iLots = 0.06; break;
      case 3: iLots = 0.12; break;
      case 4: iLots = 0.24; break;
      case 5: iLots = 0.48; break;
      case 6: iLots = 0.96; break;
      case 7: iLots = 1.92; break;
      case 8: iLots = 2.0; break;
      case 9: iLots = 3.0; break;
      case 10: iLots = 3.5; break;
      case 11: iLots = 4.0; break;
      case 12: iLots = 4.5; break;
   }
        
      


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
                        if(STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera = Time[0] + MinuteFinish*60;
                     }   
                     
                     if(OrderType()==OP_SELL )
                     {
                     
                      if(STOPTUDO2==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera = Time[0] + MinuteFinish*60;
                      
                     }
                  
                  }//FIM ORDERMAGIC
                  
                 
  
                }//FIM SELECT 
           
            }//FIM CONTADOR  
        
      
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
         //if(MA9>MA14 && Open[0]>MA9 && RSI>50 )    ordembuy = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,Ask+TakeProfit*MyPoint,Robo,MagicNumber,0,Blue);
         if(MA9<MA14 && Open[0]<MA9 && RSI<50 )    ordemsell = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,Bid+StopLoss*MyPoint,Bid-TakeProfit*MyPoint,Robo,MagicNumber,0,Red);
      }    
  }     

            for(int i2=OrdersTotal()-1; i2>=0; i2--)   
            {
               if(OrderSelect(i2,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {  
                     if(OrderType()==OP_BUY)
                     {
                        if(Ask+Distancia*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,Slippage,Bid+StopLoss*MyPoint,Bid-TakeProfit*MyPoint,NULL,MagicNumber,0,clrGreenYellow);
                     break;}
                     
                     if(OrderType()==OP_SELL)
                     {
                     if(Bid-Distancia*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,Slippage,Ask-StopLoss*MyPoint,Ask+TakeProfit*MyPoint,NULL,MagicNumber,0,clrGreenYellow);   
break;
                     }
                     }}}
               
  }//FIM ONTICK
 