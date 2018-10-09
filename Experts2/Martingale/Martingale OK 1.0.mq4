

string Robo = "Martingale OK 1.0";
extern int Slippage = 3;
extern int MagicNumber = 121212;
extern int MagicNumber2 = 131313;
extern int TAKE = 15;
extern int STOP = 10;
extern double Lots = 0.01;

double Spread=MarketInfo(Symbol(),MODE_SPREAD);
int ticket,NumOfTrades;
datetime tempo;
double iLots;

int OnInit(){return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;               
      
//=========================MEDIAS MOVEIS
      double MA = iMA(Symbol(),NULL,21,0,MODE_EMA,PRICE_CLOSE,0);
      
//=========================LOTES  
  iLots = Lots+(NumOfTrades*0.01);    
//=========================CONTADORES
      NumOfTrades = CountTrades();
           
     
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++FECHAR TODAS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
   
      
         static int closedOrders=0;
         if(OrdersHistoryTotal()!=closedOrders)
         {
            closedOrders=OrdersHistoryTotal();
            int hstTotal = OrdersHistoryTotal(); 
        
            if(OrderSelect(hstTotal-1,SELECT_BY_POS,MODE_HISTORY))
            {
               if(OrderMagicNumber()==MagicNumber)
               {  
                      
                  tempo = OrderCloseTime();
                  if(OrderType()==OP_SELL)
                  { 
                     if(OrderOpenPrice()>OrderClosePrice())  bool STOPTUDO = true;

                  }//FIM OP_SELL
               
                  if(OrderType()==OP_BUY)
                  {
                     if(OrderOpenPrice()<OrderClosePrice())  bool STOPTUDOb = true;

                  }      
               }//FIM MAGICNUMBER
               
              
           }//FIM ORDERSELECT
           
        }//FIM ORDERHISTORY 

               
            int v, totalv=OrdersTotal();
            for(int i=OrdersTotal()-1; i>=0; i--)   
            {
               if(OrderSelect(v,SELECT_BY_POS)==true)
               {
                  if(OrderMagicNumber()==MagicNumber)
                  {
                     
                 
                 if( STOPTUDO==true || STOPTUDOb==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                 }//FIM MAGICNUMBER
                 
                  
           
                 }//FIM SELECT
            }//FIM CONTADOR  
 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    if(Time[0]>=tempo+500)
   {
      if(OrdersTotal()==0)
      { 
        if(Bid+20*MyPoint<=MA)
         {
            ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,0,0,Bid-TAKE*MyPoint,Robo,MagicNumber,0,Red); 
         }   
        
         if(Ask-20*MyPoint>=MA)
         {
         ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,0,0,Ask+TAKE*MyPoint,Robo,MagicNumber,0,Blue);
         } 
    
        
      }//FIM ORDERSTOTAL
    }//FIM TIME

    
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++SOBRE ENVIO MAGIC1++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
   if(NumOfTrades<=50)
   {      
   for (int trade=OrdersTotal()-1; trade>=0; trade--) 
   {
      if (OrderSelect(trade,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {
          
            
            if(OrderType()==OP_SELL)
            {
                if(Bid-STOP*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,Bid-(TAKE+NumOfTrades)*MyPoint,NULL,MagicNumber,0,Red);
               break; 
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
              if(Ask+STOP*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,Ask+(TAKE+NumOfTrades)*MyPoint,NULL,MagicNumber,0,Blue);
               break;
           }//FIM OP_BUY
           
                 
         }//FIM MAGICNUMBER 
      }//FIM ORDERSELECT     
   }//FIM CONTADOR
  }


  }//FIM ONTICK
  


//=========================CONTADOR DE ORDEM MAGICNUMBER
  
   int CountTrades() {
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
        
   }
   return (count);
}


