/*========DESCRIÇÃO Martingale====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================
NO MARTINGALE
========================================================================================================================*/


static input string Option1 = "--------Options Basic";
extern int Slippage = 3;
extern int MagicNumber = 9090909; //BUY
extern int StopLoss = 15;
extern int TakeProfit = 8;
extern double Lots = 0.01;

static input string Option2 = "--------Options TrallingStop";
extern int TrallingStop = 10;
extern int TrallingStep = 10;

static input string Option4 = "--------Other Options";
extern int PipsCandle=10; 
extern int DistancePips=3; 
extern int MinuteFinish = 30; //encerrar ordem pendente
extern int WaitOrder = 6;


string Robo = "";
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
            ordemsell = OrderSend(Symbol(),OP_SELLSTOP,Lots,Open[0]-DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Red);
         } 
    }   

    if((countsell==0 && countsellstop==0) && (countbuy==0 && countbuystop==0))
    {
         if(Bid+PipsCandle*MyPoint<Open[0])
         {
           ordembuy = OrderSend(Symbol(), OP_BUYSTOP,Lots,Open[0]+DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Blue);
           ordemsell = OrderSend(Symbol(),OP_SELLSTOP,Lots,Close[0]-DistancePips*MyPoint,Slippage,0,0,Robo,MagicNumber,0,Red); 
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
              
                  if(SL==0 && OrderClosePrice()-TakeProfit*MyPoint>stnewpricebuy) modify = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(TakeProfit-3)*MyPoint,0,0,clrLightGreen);
                  
                  if(SL>0 && (Bid>OrderStopLoss()+TakeProfit*MyPoint))   modify = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+(TakeProfit-3)*MyPoint,0,0,clrLightGreen);
               
                  if(OrderClosePrice()+StopLoss*MyPoint<stnewpricebuy) modify = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
               
               }//FIM OP_BUY  
   
                if(OrderType()==OP_SELL)
                {
                  
                  double stnewpricesell = OrderOpenPrice();
                  double SLsell = OrderStopLoss();
               
                  if(SLsell==0 && OrderClosePrice()+TakeProfit*MyPoint<stnewpricesell) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(TakeProfit-3)*MyPoint,0,0,clrLightGreen);
                  
                  if(SLsell>0 && (Ask<OrderStopLoss()-TakeProfit*MyPoint))  ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()-(TakeProfit-3)*MyPoint,0,0,clrLightGreen);
                  
                  if(OrderClosePrice()-StopLoss*MyPoint>stnewpricesell) modify = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE); 
               
               }//FIM OP_SELL
              
              
              
               
          }//FIM MAGIC
        }//FIM SELECT
    }//FIM CONTADOR  


               
  }//FIM ONTICK
 