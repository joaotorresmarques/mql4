/*========DESCRI플O Martingale====== 

=======================*/

/*=======================================================ANOTA합ES========================================================
abrir proxima ordem com Newbar() ?
========================================================================================================================*/

static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; 

extern int StopLoss = 10;
extern double Lots = 0.01;
extern int MinuteFinish = 50;

static input string Option2 = "--------Options TrallingStop";
extern int TrallingStop =10;
extern int TrallingStep = 3;


string Robo = "Uni 2.2";
int ticket,takeBUY,takeSELL,takeBUY2,takeSELL2,stopBUY,stopSELL;
double iLots,iLots2,lote;
datetime espera,espera2;



int ordembuy,ordemsell,ordembuy2,ordemsell2;

int OnInit(){return(INIT_SUCCEEDED);}

void OnTick()
{        
   int count,countbuy,countsell;
   int count2,countbuy2,countsell2;
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

   
//=========================CONFIGURA플O DE LOTE    
 switch(count) 
   {
      case 0: iLots = Lots; break;
      case 1: iLots = 0.02; break;
      case 2: iLots = 0.05; break;
      case 3: iLots = 0.08; break;
      case 4: iLots = 0.10; break;
      case 5: iLots = 0.08; break;
      case 6: iLots = 0.11; break;
      case 7: iLots = 0.15; break;
      case 8: iLots = 0.26; break;
      case 9: iLots = 0.29; break;
      case 10: iLots = 0.34; break;
   }
      if(count>=10) iLots = count*0.06;   
      
//=========================CONFIGURA플O DE LOTE MAGIC2    
        
   iLots2 = 0.02;   
//=========================CONFIGURA플O DE TAKES   
    switch(countsell) 
   {
      case 0: takeSELL = TrallingStop;       break;
      case 1: takeSELL = TrallingStop+1;  break;
      case 2: takeSELL = TrallingStop+1; break;
      case 3: takeSELL = TrallingStop+1; break;
      case 4: takeSELL = TrallingStop+1; break;
      case 5: takeSELL = TrallingStop+1; break;
      case 6: takeSELL = TrallingStop+1; break;
      case 7: takeSELL = TrallingStop+1; break;
      case 8: takeSELL = TrallingStop+1; break;
      case 9: takeSELL = TrallingStop+1; break;
   } 
   if(count >= 10) takeSELL = TrallingStop+8;
   
    switch(countbuy) 
   {
      case 0: takeBUY = TrallingStop;       break;
      case 1: takeBUY = TrallingStop+1; break;
      case 2: takeBUY = TrallingStop+1; break;
      case 3: takeBUY = TrallingStop+1; break;
      case 4: takeBUY = TrallingStop+1; break;
      case 5: takeBUY = TrallingStop+1; break;
      case 6: takeBUY = TrallingStop+1; break;
      case 7: takeBUY = TrallingStop+1; break;
      case 8: takeBUY = TrallingStop+1; break;
      case 9: takeBUY = TrallingStop+1; break; 
   } 
   if(count >= 10) takeBUY = TrallingStop+8;   
   
   

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
         if(MA9>MA14 && Open[0]>MA9 && RSI>50)    ordembuy = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,Ask+TrallingStop*MyPoint,Robo,MagicNumber,0,Blue);
         if(MA9<MA14 && Open[0]<MA9 && RSI<50 )    ordemsell = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,Bid-TrallingStop*MyPoint,Robo,MagicNumber,0,Red);
      }    
  }     

            if(OrderSelect(ordembuy,SELECT_BY_TICKET,MODE_TRADES))
            {  
               if(countbuy>=1)
               {
                  if(OrderType()==OP_BUY)
                  { 
                     if(Ask+StopLoss*MyPoint<OrderOpenPrice()) ordembuy = OrderSend(Symbol(),OP_BUY,iLots,Ask,Slippage,0,Ask+takeBUY*MyPoint,Robo,MagicNumber,0,clrGreenYellow);
                                                                                        
                  }  
               }
            }
           
            if(OrderSelect(ordemsell,SELECT_BY_TICKET,MODE_TRADES))
            {  
               if(countsell>=1)
               {
                  if(OrderType()==OP_SELL)
                  {
                     if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ordemsell = OrderSend(Symbol(),OP_SELL,iLots,Bid,Slippage,0,Bid-takeSELL*MyPoint,Robo,MagicNumber,0,clrGreenYellow);
                                                                                        
                  }  
               }
            }


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP MAGIC1+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
 
   





               
  }//FIM ONTICK
 