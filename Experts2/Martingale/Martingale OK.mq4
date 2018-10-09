/*========DESCRIÇÃO RECOMECO====== 

  
=======================*/

/*=======================================================ANOTAÇÕES========================================================
OK. O SISTEMA DA DANDO LUCRO. 5MIN.

FALTA FAZER:

   .extern int martingale?=true
   .extern MaxOrdersAberto?=true
   .lot depedendo do valor da conta.
   .Colocar esse sistema e o BB Money no market.

      
========================================================================================================================*/

string Robo = "Martingale OK";
extern bool Suicide = true;
extern int Slippage = 3;
extern int MagicNumber = 121212;
extern int MagicNumber2 = 131313;
extern int TAKE = 5;
extern int STOP = 5;
extern double Lots = 0.01;


bool suicidio;
double Spread=MarketInfo(Symbol(),MODE_SPREAD);
int ticket,NumOfTrades,modify;
datetime tempo;
double iLots,ultimolot,balanco;

int OnInit()
{
return(INIT_SUCCEEDED);}
  
void OnTick()
  {     

//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;               
      

//=========================LOTES
      iLots = Lots+(NumOfTrades*0.02);
     
      
//=========================CONTADORES
      NumOfTrades = CountTrades();
           
//=========================SUICIDIO OBRIGATORIO
      if(NumOfTrades>100 ) bool suicideon=true;   //nao ta pegando assim!      
    
      
              
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
                 
                 if( STOPTUDO==true || STOPTUDOb==true || suicideon==true)  ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                  } 
                } 
           
            }//FIM CONTADOR  
 
if(suicideon==true){ balanco = AccountBalance(); Lots = 0.8; } 
if(AccountBalance()>balanco+20){ Lots = 0.01; } 
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    if(Time[0]>=tempo+1000)
   {
      if(OrdersTotal()==0)
      { 
        if(Open[0]+10*MyPoint<Open[1] )  ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,Ask+TAKE*MyPoint,Robo,MagicNumber,0,Blue);
        
        if(Open[0]-10*MyPoint>Open[1] ) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,Bid-TAKE*MyPoint,Robo,MagicNumber,0,Red);

        
      }//FIM ORDERSTOTAL
    }//FIM TIME

    
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++SOBRE ENVIO MAGIC1++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
          
   for (int trade=OrdersTotal()-1; trade>=0; trade--) 
   {
      if (OrderSelect(trade,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         {

            if(OrderType()==OP_SELL)
            {
                if(Bid-STOP*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,iLots,Bid,0,0,Bid-(TAKE+NumOfTrades+4)*MyPoint,NULL,MagicNumber,0,Red);
                break; 
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
              if(Ask+STOP*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,iLots,Ask,0,0,Ask+(TAKE+NumOfTrades+4)*MyPoint,NULL,MagicNumber,0,Blue);
               break;
           }//FIM OP_BUY
           
           
            
                 
         }//FIM MAGICNUMBER 
      }//FIM ORDERSELECT     
   }//FIM CONTADOR



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


