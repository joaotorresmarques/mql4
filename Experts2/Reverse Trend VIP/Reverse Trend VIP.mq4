/*========DESCRIÇÃO Martingale VIP====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================
murrey EA datas.
              
              estudar a possibilidade de inserir MAGIC3 que é lot ao maximo. primeiras ordens não seguem a tendencia.
              backtest ta foda. tenho q rever
========================================================================================================================*/

static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; //BUY
extern int MagicNumber2 = 8080808; //SELL
extern int StopLoss = 5;
extern int TakeProfit =10;
extern double Lots = 0.01;
extern double LotsMult = 0.02; //testar apenas 0.02 e aumentar take

static input string Option2 = "--------Options TrallingStop";
extern bool UseTralling = true;
extern int TrallingStop =8;
extern int TrallingStep = 5;


static input string Option3 = "--------Options Martingale";
extern bool UseMartingale = true;
extern double LotsMultMartingale = 0.06;
extern int CountOrdBeginMartingale = 9;
extern int MaxOrders = 100;

static input string Option4 = "--------Other Options";
extern int PipsCandle=15; //alterar em outra moeda
extern int DistancePips=5; //alterar em outra moeda.
extern int MinuteFinish = 6; //6minutos para encerrar ordem pendente
extern int WaitOrder = 30;  //8 minutos para iniciar uma nova ordem pendente

static input string Option5 = "--------Options DATE";
//Estudar a possibilidade de inserir dias que irá ligar. otimo pra noticias.


static input string CONTACT = "Joaotorresmarques1@Gmail.com";

string Robo = "Reverse Trend VIP";
int ticket,takeBUY,takeSELL;
double iLots,lote;
datetime espera;






int OnInit(){return(INIT_SUCCEEDED);}
  
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
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
         if (OrderType() == OP_BUYSTOP) countbuystop++; 
         if (OrderType() == OP_BUY) countbuy++;    
      }
         
       if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber2)
       {
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
         if (OrderType() == OP_SELLSTOP) countsellstop++; 
         if (OrderType() == OP_SELL) countsell++;    
       }
   } 


//=========================LOTES
      if(count>=1)   iLots = count*LotsMult;
      //if(count>CountOrdBeginMartingale)  iLots = count*LotsMultMartingale;
      
      
//=========================CONFIGURAÇÃO DE TAKES   
    switch(countsell) 
   {
      case 0: takeSELL = TrallingStop;   break;
      case 1: takeSELL = TrallingStop*1; break;
      case 2: takeSELL = TrallingStop*2; break;
      case 3: takeSELL = TrallingStop*2; break;
      case 4: takeSELL = TrallingStop*2; break;
      case 5: takeSELL = TrallingStop*2; break;
      case 6: takeSELL = TrallingStop*2; break;
      case 7: takeSELL = TrallingStop*2; break;
      case 8: takeSELL = TrallingStop*2; break;
      case 9: takeSELL = TrallingStop*3;  break;
   } 
   if(count >= 10) takeSELL = TrallingStop*5;
   
    switch(countbuy) 
   {
      case 0: takeBUY = TrallingStop;   break;
      case 1: takeBUY = TrallingStop*1; break;
      case 2: takeBUY = TrallingStop*1; break;
      case 3: takeBUY = TrallingStop*2; break;
      case 4: takeBUY = TrallingStop*2; break;
      case 5: takeBUY = TrallingStop*2; break;
      case 6: takeBUY = TrallingStop*2; break;
      case 7: takeBUY = TrallingStop*2; break;
      case 8: takeBUY = TrallingStop*2; break;
      case 9: takeBUY = TrallingStop*2; break;
   } 
   if(count >= 10) takeBUY = TrallingStop*5;      
         
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
                     if(OrderOpenPrice()<OrderClosePrice())bool STOPTUDOb = true; espera = OrderCloseTime()+WaitOrder*60;
                    

                  }//FIM OP_BUY
                     
               }//FIM MAGICNUMBER 
               
               if(OrderMagicNumber()==MagicNumber2)
               {  
                  if(OrderType()==OP_SELL)
                  { 
                     if(OrderOpenPrice()>OrderClosePrice())bool   STOPTUDO2 = true;espera = OrderCloseTime()+WaitOrder*60;
                     

                  }//FIM OP_SELL
               }
           }//FIM ORDERSELECT
        }//FIM ORDERHISTORY 
            
           if(UseTralling==true)
           {
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(i,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {  
                     if(OrderType()==OP_BUY)
                     {
                        if(STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                     }   
                  
                  }//FIM ORDERMAGIC 
                  
                  if(OrderMagicNumber()==MagicNumber2)
                  {  if(OrderType()==OP_SELL )
                     {
                      if(STOPTUDO2==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                     }
                     }
                }//FIM SELECT 
           
            }//FIM CONTADOR  
     }
      
              
                           
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  if(TimeCurrent()>espera)
  {
  if(UseTralling==true)
  {
    if((countbuy==0 && countbuystop==0) && (countsell==0 && countsellstop==0)  )
    {
         if(Ask-PipsCandle*MyPoint>Open[0])
         {
            ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots,Close[0]+DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue);
            ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Open[0]-DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber2,0,Red);
         } 
    }   
   
    
    
    if((countsell==0 && countsellstop==0) && (countbuy==0 && countbuystop==0))
    {
      if(Bid+PipsCandle*MyPoint<Open[0])
      {
          ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots,Open[0]+DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue);
          ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Close[0]-DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber2,0,Red);
          
      }        
      
    } 
  }//FIM TRUE usetralling
  
  if(UseTralling==false)
  {  
  
      if((countbuy==0 && countbuystop==0) && (countsell==0 && countsellstop==0)  )
    {
         if(Ask-PipsCandle*MyPoint>Open[0])
         {
            ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots,Close[0]+DistancePips*MyPoint,Slippage,Ask-StopLoss*MyPoint,Ask+StopLoss*MyPoint,Robo,MagicNumber,0,Blue);
            ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Open[0]-DistancePips*MyPoint,Slippage,Bid+StopLoss*MyPoint,Bid-StopLoss*MyPoint,Robo,MagicNumber2,0,Red);
         } 
    }   
   
    
    
    if((countsell==0 && countsellstop==0) && (countbuy==0 && countbuystop==0))
    {
      if(Bid+PipsCandle*MyPoint<Open[0])
      {
          ticket = OrderSend(Symbol(), OP_BUYSTOP,Lots,Close[0]+DistancePips*MyPoint,Slippage,Ask-StopLoss*MyPoint,Ask+StopLoss*MyPoint,Robo,MagicNumber,0,Blue);
          ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,Open[0]-DistancePips*MyPoint,Slippage,Bid+StopLoss*MyPoint,Bid-StopLoss*MyPoint,Robo,MagicNumber2,0,Red);
          
      }        
      
    } 
   
    
   }//FIM Usetralling FALSE 
    
    
    }//fim TIMECURRENT

//++++++++++++++++++++++++++++++++++++++++++++++++++ENCERRAR ORDENS PENDENTES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    for (int trade7=OrdersTotal()-1; trade7>=0; trade7--) 
   {
      if (OrderSelect(trade7,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {    
            if(OrderType()==OP_BUYSTOP)
            {   
               if(OrderOpenTime()<Time[0]-MinuteFinish*60) ticket = OrderDelete(OrderTicket(),Green);  
            }//FIM OP_BUYSTOP
            
           }
           if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
            {  
            if(OrderType()==OP_SELLSTOP)
            {  
               if(OrderOpenTime()<Time[0]-MinuteFinish*60) ticket = OrderDelete(OrderTicket(),Green); 
            }//FIM OP_SELLSTOP
             
         }//FIM MAGIC
      }//FIM ORDERSELECT
    }//FIM CONTADOR
    

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
  if(UseTralling==true)
  {
    for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MagicNumber || OrderMagicNumber()==MagicNumber2) )
         {  
               if(OrderType()==OP_BUY)
               {
                  double stnewpricebuy = OrderOpenPrice();
                  double SL = OrderStopLoss();
                  
                  if(SL==0 && Ask+takeBUY*MyPoint>stnewpricebuy) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+takeBUY*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (OrderStopLoss()<(Ask+TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SL+TrallingStep*MyPoint,0,0,clrLightGreen);
                  
  
               }//FIM OP_BUY
               
                if(OrderType()==OP_SELL)
                {
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && Bid-takeSELL*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricesell-takeSELL*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (OrderStopLoss()>(Bid-TrallingStep*MyPoint)))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLsell-TrallingStep*MyPoint,0,0,clrLightGreen);

               
               }//FIM OP_SELL
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR  
    
  }//FIM Usetralling TRUE  
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ENVIO DE ORDEM MARTINGAE++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
   
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
           
           
           if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
         {
             if(OrderType()==OP_SELL)
             {
                if(Bid-StopLoss*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,Slippage,0,0,NULL,MagicNumber2,0,clrGreenYellow);
                break; 
             }//FIM OP_SELL      
         }//FIM MAGICNUMBER 
      }//FIM ORDERSELECT     
   }//FIM CONTADOR  
  }//FIM MAX ORDERS
   
  }//FIM UseMartingale TRUE
   

  }//FIM ONTICK
  

