/*========DESCRI플O Martingale====== 

=======================*/

/*=======================================================ANOTA합ES========================================================

========================================================================================================================*/

static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; 
extern int MagicNumber2 = 808080;
extern int StopLoss = 10;
extern double Lots = 0.01;
extern int MinuteFinish = 15;

static input string Option2 = "--------Options TrallingStop";
extern int TrallingStop =8;
extern int TrallingStep = 3;


string Robo = "Uni 2.2";
int ticket,takeBUY,takeSELL,takeBUY2,takeSELL2;
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
      
         if(OrderMagicNumber()==MagicNumber2)
         {
            if (OrderType() == OP_SELL || OrderType() == OP_BUY) count2++;
            if(OrderType()==OP_BUY) countbuy2++;
            if(OrderType()==OP_SELL) countsell2++;
         }   
        
     }
   }
//se money=10 entao lot0.01... money=20 lot 0.02...... 
   
//=========================CONFIGURA플O DE LOTE    
 switch(count) 
   {
      case 0: iLots = Lots; break;
      case 1: iLots = 0.02; break;
      case 2: iLots = 0.02; break;
      case 3: iLots = 0.03; break;
      case 4: iLots = 0.05; break;
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
      case 1: takeSELL = TrallingStop+1; break;
      case 2: takeSELL = TrallingStop+1; break;
      case 3: takeSELL = TrallingStop+1; break;
      case 4: takeSELL = TrallingStop+1; break;
      case 5: takeSELL = TrallingStop+1; break;
      case 6: takeSELL = TrallingStop+1; break;
      case 7: takeSELL = TrallingStop+1; break;
      case 8: takeSELL = TrallingStop+1; break;
      case 9: takeSELL = TrallingStop+2; break;
   } 
   if(count >= 10) takeSELL = TrallingStop;
   
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
      case 9: takeBUY = TrallingStop+2; break; //&&Trallingstop =10
   } 
   if(count >= 10) takeBUY = TrallingStop+count;   
   
   
//=========================CONFIGURA플O DE TAKES MAGIC2   
    switch(countsell2) 
   {
      case 0: takeSELL2 = TrallingStop;       break;
      case 1: takeSELL2 = TrallingStop+1; break;
      case 2: takeSELL2 = TrallingStop+1; break;
      case 3: takeSELL2 = TrallingStop+1; break;
      case 4: takeSELL2 = TrallingStop+1; break;
      case 5: takeSELL2 = TrallingStop+1; break;
      case 6: takeSELL2 = TrallingStop+1; break;
      case 7: takeSELL2 = TrallingStop+1; break;
      case 8: takeSELL2 = TrallingStop+1; break;
      case 9: takeSELL2 = TrallingStop+2; break;
   } 
   if(count2 >= 10) takeSELL2 = TrallingStop+count2+9;
   
    switch(countbuy2) 
   {
      case 0: takeBUY2 = TrallingStop;       break;
      case 1: takeBUY2 = TrallingStop+1; break;
      case 2: takeBUY2 = TrallingStop+1; break;
      case 3: takeBUY2 = TrallingStop+1; break;
      case 4: takeBUY2 = TrallingStop+1; break;
      case 5: takeBUY2 = TrallingStop+1; break;
      case 6: takeBUY2 = TrallingStop+1; break;
      case 7: takeBUY2 = TrallingStop+1; break;
      case 8: takeBUY2 = TrallingStop+1; break;
      case 9: takeBUY2 = TrallingStop+2; break;
   } 
   if(count2 >= 10) takeBUY2 = TrallingStop+count2+9;      
      
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
               
               if(OrderMagicNumber()==MagicNumber2)
               {  
                  if(OrderType()==OP_BUY)
                  {
                     if(OrderOpenPrice()<OrderClosePrice()) bool STOPTUDOb2 = true; 
                    
                  }//FIM OP_BUY
                  
                  if(OrderType()==OP_SELL)
                  { 
                     if(OrderOpenPrice()>OrderClosePrice()) bool STOPTUDO22 = true;
                     
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
                  
                  if(OrderMagicNumber()==MagicNumber2)
                  {  
                     if(OrderType()==OP_BUY)
                     {
                        if(STOPTUDOb2==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera2 = Time[0] + MinuteFinish*60;
                     }   
                     
                     if(OrderType()==OP_SELL )
                     {
                     
                      if(STOPTUDO22==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera2 = Time[0] + MinuteFinish*60;
                      
                     }
                  
                  }//FIM ORDERMAGIC 
  
                }//FIM SELECT 
           
            }//FIM CONTADOR  
         
      
//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
 
//=========================MEDIAS MOVEIS      
      double MA4 = iMA(Symbol(),NULL,4,0,MODE_EMA,PRICE_CLOSE,0);
      double MA21 = iMA(Symbol(),NULL,21,0,MODE_EMA,PRICE_CLOSE,0);
      double MA50 = iMA(Symbol(),NULL,50,0,MODE_EMA,PRICE_CLOSE,0);
      
    if(OrdersTotal()==0){ ordembuy=0; ordemsell=0; ordembuy2=0; ordemsell2=0;}                     
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM MAGIC1 E MARTINGALE ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  if(Time[0]>espera)
  {
      if(OrdersTotal()==0)
      { 
         if((MA4-3*MyPoint>MA21) && MA21>MA50)    ordembuy = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,Robo,MagicNumber,0,Blue);
         if((MA4+3*MyPoint<MA21) && MA21<MA50)    ordemsell = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,Robo,MagicNumber,0,Red);
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

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA MAGIC2 e MARTINGALE+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
 /*  if(Time[0]>espera2)
   {
      if(count2==0 &&countbuy>=1 && MA4<MA21&&MA21<MA50) ordemsell2 = OrderSend(Symbol(),OP_SELL,iLots2,Bid,Slippage,0,0,Robo,MagicNumber2,0,clrRed);
      if(count2==0 && countsell>=1 && MA4>MA21&&MA21>MA50) ordembuy2 = OrderSend(Symbol(),OP_BUY,iLots2,Ask,Slippage,0,0,Robo,MagicNumber2,0,clrBlue);
   }
*/
            if(OrderSelect(ordembuy2,SELECT_BY_TICKET,MODE_TRADES))
            {  
               if(countbuy2>=1)
               {
                  if(OrderType()==OP_BUY)
                  { 
                     if(Ask+StopLoss*MyPoint<OrderOpenPrice()) ordembuy2 = OrderSend(Symbol(),OP_BUY,iLots2,Ask,Slippage,0,0,Robo,MagicNumber2,0,clrAqua);
                                                                                        
                  }  
               }
            }
           
            if(OrderSelect(ordemsell2,SELECT_BY_TICKET,MODE_TRADES))
            {  
               if(countsell2>=1)
               {
                  if(OrderType()==OP_SELL)
                  {
                     if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ordemsell2 = OrderSend(Symbol(),OP_SELL,iLots2,Bid,Slippage,0,0,Robo,MagicNumber2,0,clrAqua);
                                                                                        
                  }  
               }
            }

           
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP MAGIC1+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
 /*
    if(OrderSelect(ordembuy,SELECT_BY_TICKET,MODE_TRADES))
    { 
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
              
                  if(SL==0 && Ask+TrallingStop*MyPoint>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+(takeBUY-1)*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (OrderStopLoss()<(Ask+TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL+TrallingStep*MyPoint,0,0,clrLightGreen);
    }//FIM BUY  
   
    if(OrderSelect(ordemsell,SELECT_BY_TICKET,MODE_TRADES))
    { 
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && Bid-TrallingStop*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell-takeSELL*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (OrderStopLoss()>(Bid-TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell-TrallingStep*MyPoint,0,0,clrLightGreen);
     }//FIM SELL
              
      */         




//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP MAGIC2+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
/*
    if(OrderSelect(ordembuy2,SELECT_BY_TICKET,MODE_TRADES))
    { 
                  double stnewpricebuy2 = OrderOpenPrice();
                  double SL2 = OrderStopLoss();
              
                  if(SL2==0 && Ask+takeBUY2*MyPoint>stnewpricebuy2) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy2+takeBUY2*MyPoint,0,0,clrLightGreen);
                  
                  if(SL2>0 && (OrderStopLoss()<(Ask+TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL2+TrallingStep*MyPoint,0,0,clrLightGreen);
    }//FIM BUY  
   
    if(OrderSelect(ordemsell2,SELECT_BY_TICKET,MODE_TRADES))
    { 
                  double stnewpricesell2 = OrderOpenPrice();
                  double SLsell2 = OrderStopLoss();
               
                  if(SLsell2==0 && Bid-takeSELL2*MyPoint<stnewpricesell2) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell2-takeSELL2*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell2>0 && (OrderStopLoss()>(Bid-TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell2-TrallingStep*MyPoint,0,0,clrLightGreen);
     }//FIM SELL
     */         


               
  }//FIM ONTICK
 