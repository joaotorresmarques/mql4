
string Robo = "Martingale OK 1.1";
input int Slippage = 3;
input int MagicNumber1 = 121212;
input int MagicNumber2 = 131313;

double Balancoanterior;
double Lots1;
double Lots2;
double Lots3;

input double maxLots1 = 0.4; 
input double maxLots2 = 0.4;


input double defaultLot1 = 0.1;
input double defaultLot2 = 0.2;


input int TAKE1 = 5; 
input int TAKE2 = 10; 

input int STOP1 = 10;
input int STOP2 = 10;

datetime tempo;
int ticket;


  int Contfail,Contgain;
void OnTick()
  {
    
  
//||||||||||||||||||||||||||||||||||||||||||||||||||||||CONFIGURA플O DE LOTE|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

 if(AccountBalance()>Balancoanterior) //if(AccountBalance()>Balancoanterior/*+606+909+808*/)
 {                                    
    Lots1=defaultLot1;                       
    Lots2=defaultLot2;

 }
      static int closedOrders=0;
      if(OrdersHistoryTotal()!=closedOrders)
      {
         closedOrders=OrdersHistoryTotal();
         int hstTotal = OrdersHistoryTotal(); 
         int hstTotal2 = OrdersHistoryTotal(); 
         if(OrderSelect(hstTotal2-1,SELECT_BY_POS,MODE_HISTORY)){  if(OrderMagicNumber()==MagicNumber1 || OrderMagicNumber()==MagicNumber2) tempo = OrderCloseTime();}
         if(OrderSelect(hstTotal-2,SELECT_BY_POS,MODE_HISTORY))
        
         if(OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber2)
         {
            if(OrderOpenPrice()<OrderClosePrice())
            {
             
              Balancoanterior = AccountBalance();
               
             Lots1=maxLots1;
             Lots2=maxLots2;

            }
            
           
         } //FIM SELE플O OP_SELL
         
         if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber2)
         {
            if(OrderOpenPrice()>OrderClosePrice())
            { 
            
              
               Balancoanterior = AccountBalance();
               
               Lots1=maxLots1;
               Lots2=maxLots2;

            }
          } //FIM SELE플O OP_BUY        
         
      }//FIM ORDERHISTORYTOTAL()
      
      
         
      
//=========================POINT
     double MyPoint=Point;                                      
     if(Digits==3 || Digits==5) MyPoint=Point*10;               
  
//=========================MEDIAS MOVEIS
      double MA = iMA(Symbol(),NULL,21,0,MODE_EMA,PRICE_CLOSE,0);
    
     
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++       
    if(Time[0]>=tempo+500)
   {
   if(OrdersTotal()==0)   //Low[0]-20*MyPoint==MA
   {
     if(High[0]>High[1]+20*MyPoint )  /*if(Bid+20*MyPoint<=MA)*/ ticket = OrderSend(Symbol(),OP_SELL,Lots1,Bid,0,0,Bid-TAKE1*MyPoint,Robo,MagicNumber1,0,Red);   
        
     if(Low[0]-20*MyPoint == Close[0] && Ask<MA) /*if(Ask-20*MyPoint>=MA)*/ ticket = OrderSend(Symbol(),OP_BUY,Lots1,Ask,0,0,Ask+TAKE1*MyPoint,Robo,MagicNumber1,0,Blue);
   }
  }//FIM ORDERSTOTAL
  
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++CONFIGURA플O DE ORDEM MAGIC 1++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
      if(OrdersTotal()==1)
      {
      int cnt, total=OrdersTotal();
      for(cnt=0;cnt<total;cnt++)
      {
         if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber1)
         {
                     
            if(OrderType()==OP_BUY)
            {  //DEFINI플O DE STOP
               if(Ask+STOP1*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,Lots2,Ask,Slippage,0,0,Robo,MagicNumber2,0,Blue);
            }//FIM OP_BUY
            
            
            if(OrderType()==OP_SELL)
            {  //DEFINI플O DE STOP
               if(Bid-STOP1*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,Lots2,Bid,Slippage,0,0,Robo,MagicNumber2,0,Red);
            }//FIM OP_SELL      
            
            
         }//FIM ORDERMAGIC
      }//FIM CONTADOR      
      }      
               
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++CONFIGURA플O DE ORDEM MAGIC 2++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
            
            if(OrdersTotal()==2)
            {
               int cntt, totalt=OrdersTotal();
               for(cntt=0;cntt<totalt;cntt++)
               {
                  if(OrderSelect(cntt,SELECT_BY_POS,MODE_TRADES))
                  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
                  {
                     if(OrderType()==OP_SELL)
                     {  //DEFINI플O DE TAKE
                       if(Bid+TAKE2*MyPoint<OrderOpenPrice()) bool TAKESHELL2=true;
                     
                        //DEFINI플O DE STOP E ORDERSEND MAGIC3
                        if(Bid-STOP2*MyPoint>OrderOpenPrice()) bool STOPSHELL2=true;
                      
                     }
                  
                     if(OrderType()==OP_BUY)
                     {  //DEFINI플O DE TAKE
                        if(Ask-TAKE2*MyPoint>OrderOpenPrice()) bool TAKEBUY2=true; 
                     
                        if(Ask+STOP2*MyPoint<OrderOpenPrice()) bool STOPBUY2=true;

                     }
               
               }//FIM MAGIC2
             }//FIM CONTADOR
  }
  
  
  

 //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++FECHAMENTO DE TODAS AS ORDENS++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
            int v, totalv=OrdersTotal();
            for(v=0;v<totalv;v++)
            {
               if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES))
               {
                  if(OrderMagicNumber()==MagicNumber2)
                  {
                 if( TAKESHELL2==true || TAKEBUY2==true || STOPBUY2==true || STOPSHELL2==true ) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                } 
           }
            }//FIM CONTADOR  
  
  
                  
                     
    int vx, totalvx=OrdersTotal();
            for(vx=0;vx<totalvx;vx++)
            {
               if(OrderSelect(vx,SELECT_BY_POS,MODE_TRADES))
               {
                 
                 if( TAKESHELL2==true || TAKEBUY2==true || STOPBUY2==true || STOPSHELL2==true ) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                } 
           
            }//FIM CONTADOR 
  
  }//FIM ONTICK
