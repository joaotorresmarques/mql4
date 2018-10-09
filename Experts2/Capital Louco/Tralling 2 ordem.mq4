/*========DESCRIÇÃO Martingale====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================
APOS A SEGUNDA ORDEM COM TRALLING
========================================================================================================================*/
/*#property strict;
#property strict
#property  version "1.0"
#property  description "Reverse Trend" */

static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; //BUY
extern int StopLoss = 10;
extern int TakeProfit = 8;
extern double Lots = 0.01;

static input string Option2 = "--------Options TrallingStop";
extern int TrallingStop =10;
extern int TrallingStep = 10;

static input string Option4 = "--------Other Options";
extern int PipsCandle=10; 
extern int DistancePips=5; 
extern int MinuteFinish = 80; //encerrar ordem pendente
extern int WaitOrder = 6;


string Robo = "Uni 3.0";
int ticket,takeBUY,takeSELL,modify,error,stepBUY,stepSELL;
double iLots,lote;
datetime espera,espera2,espera3,espera4;


int ordembuy,ordemsell;

int OnInit(){return(INIT_SUCCEEDED);}

void OnTick()
  {        
  //=========================CONTADOR DE ORDENS ABERTAS  
   int count,countsellstop,countbuystop,countsell,countbuy;
   
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
         if (OrderType() == OP_BUYSTOP) countbuystop++; 
         if (OrderType() == OP_BUY) countbuy++;    
         if (OrderType() == OP_SELLSTOP) countsellstop++; 
         if (OrderType() == OP_SELL) countsell++;    
      }
         
    
   }//FIM CONTADOR 
   
//=========================CONFIGURAÇÃO DE LOTE    
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
      
//=========================CONFIGURAÇÃO DE TAKES   
   switch(countbuy) 
   {
      case 0: takeBUY = TrallingStop;     stepBUY = TrallingStep;            break;
      case 1: takeBUY = TrallingStop;     stepBUY = TrallingStep;            break;
      case 2: takeBUY = TrallingStop;     stepBUY = TrallingStep;            break;
      case 3: takeBUY = TrallingStop;     stepBUY = TrallingStep;            break;
      case 4: takeBUY = TrallingStop+2;   stepBUY = TrallingStep+2;          break;
      case 5: takeBUY = TrallingStop+2;   stepBUY = TrallingStep+2;          break;
      case 6: takeBUY = TrallingStop+2;   stepBUY = TrallingStep+2;          break;
      case 7: takeBUY = TrallingStop+2;   stepBUY = TrallingStep+2;          break;
      case 8: takeBUY = TrallingStop+2;   stepBUY = TrallingStep+2;          break;
      case 9: takeBUY = TrallingStop+2;   stepBUY = TrallingStep+2;          break;
   } 
   if(count >= 10) takeBUY = TrallingStop+20;   
   
    switch(countsell)                             
   {
      case 0: takeSELL = TrallingStop;    stepSELL = TrallingStep;            break;
      case 1: takeSELL = TrallingStop;    stepSELL = TrallingStep;            break;
      case 2: takeSELL = TrallingStop;    stepSELL = TrallingStep;            break;
      case 3: takeSELL = TrallingStop;    stepSELL = TrallingStep;            break;
      case 4: takeSELL = TrallingStop+2;  stepSELL = TrallingStep+2;            break;
      case 5: takeSELL = TrallingStop+2;  stepSELL = TrallingStep+2;            break;
      case 6: takeSELL = TrallingStop+2;  stepSELL = TrallingStep+2;            break;
      case 7: takeSELL = TrallingStop+2;  stepSELL = TrallingStep+2;            break;
      case 8: takeSELL = TrallingStop+2;  stepSELL = TrallingStep+2;            break;
      case 9: takeSELL = TrallingStop+2;  stepSELL = TrallingStep+2;            break;
   } 
   if(count >= 10) takeSELL = TrallingStop+20;
   
      
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
                        if(STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera = Time[0] + WaitOrder*60;
                     }   
                     
                     if(OrderType()==OP_SELL )
                     {
                     
                        if(STOPTUDO2==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); espera = Time[0] + WaitOrder*60;
                      
                     }
                  
                  }//FIM ORDERMAGIC 
  
                }//FIM SELECT 
           
            }//FIM CONTADOR  
         
      
//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
   
    if(OrdersTotal()==0){ ordembuy=0; ordemsell=0;}                     
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  if(Time[0]>espera)
  {
   if((countbuy==0 && countbuystop==0) && (countsell==0 && countsellstop==0)  )
    {
         if(Ask-PipsCandle*MyPoint>Open[0])
         {
            ordembuy = OrderSend(Symbol(), OP_BUYSTOP,Lots,Close[0]+DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue);
            ordemsell = OrderSend(Symbol(),OP_SELLSTOP,Lots,Open[0]-(DistancePips+3)*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Red);
         } 
    }   

    if((countsell==0 && countsellstop==0) && (countbuy==0 && countbuystop==0))
    {
         if(Bid+PipsCandle*MyPoint<Open[0])
         {
           ordembuy = OrderSend(Symbol(), OP_BUYSTOP,Lots,Open[0]+(DistancePips+3)*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue);
           ordemsell = OrderSend(Symbol(),OP_SELLSTOP,Lots,Close[0]-DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Red); 
         }        
      
    } 
 }     

//DEFINIR 1º ORDEM SEM TRALLINGSTOP 
   if(countbuy==1)
   {
      if(OrderSelect(ordembuy,SELECT_BY_TICKET,MODE_TRADES))
      {   
         ticket = OrderModify(OrderTicket(),OrderOpenPrice(),0,OrderOpenPrice()+TakeProfit*MyPoint,0,clrLightGreen);
      }
   }
   
   if(countsell==1)
   {
      if(OrderSelect(ordemsell,SELECT_BY_TICKET,MODE_TRADES))
      {   
         ticket = OrderModify(OrderTicket(),OrderOpenPrice(),0,OrderOpenPrice()-TakeProfit*MyPoint,0,clrLightGreen);
      }
   }
    
 
//APÓS 2 ORDENS A PRIMEIRA ORDEM FICA SEM TAKE.    
   if(Time[0]>espera4)
   {
    for (int trade35=OrdersTotal()-2; trade35>=0; trade35--) 
    {
      if (OrderSelect(trade35,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber  )
         {  
               if(OrderType()==OP_BUY)
               {
                  if(countbuy==2)
                  {
                     ticket = OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0,clrLightGreen);
                     espera4 = Time[0]+20*60;
                    
                     
                  }//FIM OP_BUY  
               }
               
                if(OrderType()==OP_SELL)
                {
                  if(countsell==2)
                  {
                     ticket = OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0,clrLightGreen);
                     espera4 = Time[0]+20*60;
                     
                  }   
               }//FIM OP_SELL
              
              
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR  
    
    }
    
   
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++MARTINGALE+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
        
    if(OrderSelect(ordembuy,SELECT_BY_TICKET,MODE_TRADES))
    {  
         if(countbuy>=1)
         {
            if(OrderType()==OP_BUY)
            { 
               if(Ask+StopLoss*MyPoint<OrderOpenPrice()) ordembuy = OrderSend(Symbol(),OP_BUY,iLots,Ask,Slippage,0,0,NULL,MagicNumber,0,clrGreenYellow); 
                                                                                 
            }
         }
    }
           
    if(OrderSelect(ordemsell,SELECT_BY_TICKET,MODE_TRADES))
    { 
         if(countsell>=1)
         {
             if(OrderType()==OP_SELL)
             {
                if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ordemsell = OrderSend(Symbol(),OP_SELL,iLots,Bid,Slippage,0,0,NULL,MagicNumber,0,clrGreenYellow);
                                                                                     
                  
             }
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
               if(OrderOpenTime()<Time[0]-MinuteFinish*60) ticket = OrderDelete(OrderTicket(),Green);  espera = Time[0] + WaitOrder*60;
            }//FIM OP_BUYSTOP
            
         }
            if(OrderType()==OP_SELLSTOP)
            {  
               if(OrderOpenTime()<Time[0]-MinuteFinish*60) ticket = OrderDelete(OrderTicket(),Green); espera = Time[0] + WaitOrder*60;
            }//FIM OP_SELLSTOP       
         
         
      }//FIM ORDERSELECT
    }//FIM CONTADOR
               
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    

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
              
                  if(SL==0 && OrderClosePrice()-takeBUY*MyPoint>stnewpricebuy) modify = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(takeBUY-4)*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (Bid>OrderStopLoss()+stepBUY*MyPoint))   modify = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+(stepBUY-3)*MyPoint,0,0,clrLightGreen);
               
               if(modify<=0) error = GetLastError();
               Comment(error);
               }//FIM OP_BUY  
   
                if(OrderType()==OP_SELL)
                {
                  
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && OrderClosePrice()+takeSELL*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(takeSELL-4)*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (Ask<OrderStopLoss()-stepSELL*MyPoint))  ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()-(stepSELL-4)*MyPoint,0,0,clrLightGreen);
               }//FIM OP_SELL
              
              
              
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR  


               
  }//FIM ONTICK
 