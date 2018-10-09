

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


string Robo = "EArsima";
int ticket,takeBUY,takeSELL,takeBUY2,takeSELL2,stopBUY,stopSELL;
double iLots,iLots2,lote;
datetime espera,espera2;
static datetime new_time = 0;
bool isNewBar(datetime& new_time)
{
   if (new_time != Time[0])               // this helps to avoid placing TRADES on the
   {                                      // same PEAK or BOTTOM multiple times.
      new_time = Time[0];                 //
      return(true);
   }
   else 
      return(false);
}

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

   
//=========================CONFIGURA플O DE LOTE    
 switch(count) 
   {
      case 0: iLots = Lots; break;
      case 1: iLots = 0.02; break;
      case 2: iLots = 0.05; break;
      case 3: iLots = 0.08; break;
      case 4: iLots = 0.10; break;
      case 5: iLots = 0.14; break;
      case 6: iLots = 0.18; break;
      case 7: iLots = 0.22; break;
      case 8: iLots = 0.27; break;
      case 9: iLots = 0.30; break;
      case 10: iLots = 0.34; break;
   }
      if(count>=10) iLots = count*0.06;   
      
//=========================CONFIGURA플O DE LOTE MAGIC2    
        
   iLots2 = 0.02;   
//=========================CONFIGURA플O DE TAKES   
    switch(countsell) 
   {
      case 0: takeSELL = TrallingStop;       break;
      case 1: takeSELL = TrallingStop;  break;
      case 2: takeSELL = TrallingStop; break;
      case 3: takeSELL = TrallingStop; break;
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
      case 1: takeBUY = TrallingStop; break;
      case 2: takeBUY = TrallingStop; break;
      case 3: takeBUY = TrallingStop; break;
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
   if(isNewBar(new_time)){
   OrderSend(Symbol(),OP_BUY,iLots,Ask,Slippage,0,Ask+takeBUY*MyPoint,Robo,MagicNumber,0,clrGreenYellow);
   }


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP MAGIC1+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
 
   





               
  }//FIM ONTICK
 