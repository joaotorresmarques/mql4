/*========DESCRI플O Martingale====== 

  
=======================*/

/*=======================================================ANOTA합ES========================================================

========================================================================================================================*/
/*#property strict;
#property strict
#property  version "1.0"
#property  description "Reverse Trend" */

static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; //BUY
extern int StopLoss = 10;
extern double Lots = 0.01;

static input string Option2 = "--------Options TrallingStop";
extern int TrallingStop =8;
extern int TrallingStep = 5;


string Robo = "Reverse Trend VIP 1.2";
int ticket,takeBUY,takeSELL;
double iLots,lote;
datetime espera;


int ordembuy,ordemsell;

int OnInit(){return(INIT_SUCCEEDED);}

void OnTick()
  {        
   int count,countbuy,countsell;
   for (int trade1=OrdersTotal()-1; trade1>=0; trade1--) 
   {
      if (OrderSelect(trade1,SELECT_BY_POS, MODE_TRADES)) 
      {  if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
      if(OrderType()==OP_BUY) countbuy++;
      if(OrderType()==OP_SELL) countsell++;
        
       }
   }
   
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
      
//=========================CONFIGURA플O DE TAKES   
    switch(countsell) 
   {
      case 0: takeSELL = TrallingStop;   break;
      case 1: takeSELL = TrallingStop+count; break;
      case 2: takeSELL = TrallingStop+count; break;
      case 3: takeSELL = TrallingStop+count; break;
      case 4: takeSELL = TrallingStop+count; break;
      case 5: takeSELL = TrallingStop+count; break;
      case 6: takeSELL = TrallingStop+count; break;
      case 7: takeSELL = TrallingStop+count; break;
      case 8: takeSELL = TrallingStop+count; break;
      case 9: takeSELL = TrallingStop+count;  break;
   } 
   if(count >= 10) takeSELL = TrallingStop+count;
   
    switch(countbuy) 
   {
      case 0: takeBUY = TrallingStop;   break;
      case 1: takeBUY = TrallingStop+count; break;
      case 2: takeBUY = TrallingStop+count; break;
      case 3: takeBUY = TrallingStop+count; break;
      case 4: takeBUY = TrallingStop+count; break;
      case 5: takeBUY = TrallingStop+count; break;
      case 6: takeBUY = TrallingStop+count; break;
      case 7: takeBUY = TrallingStop+count; break;
      case 8: takeBUY = TrallingStop+count; break;
      case 9: takeBUY = TrallingStop+count; break;
   } 
   if(count >= 10) takeBUY = TrallingStop+count;   
      
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
                        if(STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera = Time[0] + 2*60;
                     }   
                     
                     if(OrderType()==OP_SELL )
                     {
                     
                      if(STOPTUDO2==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera = Time[0] + 2*60;
                      
                     }
                  
                  }//FIM ORDERMAGIC 
  
                }//FIM SELECT 
           
            }//FIM CONTADOR  
         
      
//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
   
    if(OrdersTotal()==0){ ordembuy=0; ordemsell=0;}                     
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  if(Time[0]>espera){
  if(OrdersTotal()==0)
  {
    ordembuy = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,Ask+TrallingStop*MyPoint,NULL,MagicNumber,0,Blue);
    ordemsell = OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,Bid-TrallingStop*MyPoint,NULL,MagicNumber,0,Red);
  }    
   }     

            if(OrderSelect(ordembuy,SELECT_BY_TICKET,MODE_TRADES))
            {  
               if(countbuy>=1)
               {
                  if(OrderType()==OP_BUY)
                  { 
                     if(Ask+StopLoss*MyPoint<OrderOpenPrice()) ordembuy = OrderSend(Symbol(),OP_BUY,iLots,Ask,Slippage,0,Ask+TrallingStop*MyPoint,NULL,MagicNumber,0,clrGreenYellow);
                                                                                        
                  }  
               }
            }
           
            if(OrderSelect(ordemsell,SELECT_BY_TICKET,MODE_TRADES))
            {  
               if(countsell>=1)
               {
                  if(OrderType()==OP_SELL)
                  {
                     if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ordemsell = OrderSend(Symbol(),OP_SELL,iLots,Bid,Slippage,0,Bid-TrallingStop*MyPoint,NULL,MagicNumber,0,clrGreenYellow);
                                                                                        
                  }  
               }
            }
           
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
 /*
    for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber  )
         {  
               if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
              
                  if(SL==0 && Ask+TrallingStop*MyPoint>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+(takeBUY-1)*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (OrderStopLoss()<(Ask+TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL+TrallingStep*MyPoint,0,0,clrLightGreen);
               }//FIM OP_BUY  
   
                if(OrderType()==OP_SELL)
                {
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && Bid-TrallingStop*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell-(takeSELL-1)*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (OrderStopLoss()>(Bid-TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell-TrallingStep*MyPoint,0,0,clrLightGreen);
               }//FIM OP_SELL
              
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR  

*/
               
  }//FIM ONTICK
 