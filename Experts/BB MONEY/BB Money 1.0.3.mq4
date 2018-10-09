/*========DESCRIÇÃO BB Money 1.0.3====== 

1) Ask ou Bid atingir As bandas aciona a MAGIC1
2) Se MAGIC1 atingir -STOP1 então aciona MAGIC2
3) Se MAGIC2 atingir -STOP2 então aciona MAGIC3
4) Se MAGIC3 atingir -STOP3 então fui stopado.
4.1) As demais ordens quando atingir TAKE é concluido a operação com exito.

*Calculo de LOTE aumentativo se MAGIC3 for NEGATIVO no historico (Apenas com a proxima ordem).

  
=======================*/


/*=======================================================ANOTAÇÕES========================================================


========================================================================================================================*/
string Robo = "BB Money 1.0.3";
input int Slippage = 6;
input int MagicNumber1 = 8001;
input int MagicNumber2 = 8002;
input int MagicNumber3 = 8003;

double Balancoanterior;
double Lots1;
double Lots2;
double Lots3;

input double maxLots1 = 1.0; 
input double maxLots2 = 2.0;
input double maxLots3 = 4.0; //era 3. coloquei 4.

input double defaultLot1 = 0.1;
input double defaultLot2 = 0.2;
input double defaultLot3 = 0.6;

input int TAKE1 = 20; 
input int TAKE2 = 20; //era 15
input int TAKE3 = 10; //Se eu colocar 5 como antes ele fica horrivel. 10 fica lindo demais!

input int STOP1 = 20;
input int STOP2 = 10; 
input int STOP3 = 30; //Analisar os GAIN de magic3 até quanto ta bom colocar. acho que ta muito grande, nao necessita disso tudo.

input int MinutesWait = 60;
datetime MAGIC3;
int ticket;

int OnInit()
  {
/* Comment(  "Expert Advisor         ",Robo,"\n",
           "Valor Inicial          ","R$80.00 USD","\n",
           "Valor Atualizado       ",AccountEquity(),"\n",
           "Ganho/Perda            ","teste","\n","\n",
           
           "MagicNumbers           ",MagicNumber1,"  ",MagicNumber2,"  ",MagicNumber3,"  ","\n",
           "Lots Default           ",Lots1,"  ",Lots2,"  ",Lots3,"  ","\n",
           "Lots Max               ",defaultLot1,"  ",defaultLot2,"  ",defaultLot3,"  ","\n",
           "-------------");
    
    if (MarketInfo(Symbol(),MODE_SPREAD) >6)
    {
      Comment("Spread maior que 6. Aguardando reduzir!");
      return; //testar depois.
    }
      
    if (Symbol() != "EURUSD")
    {
		Comment(Symbol(),"  É diferente que EURUSD. ");
		return; //testar depois.
	 }  
	 
   if (AccountEquity()<9500)
    {
		Comment("Dinheiro esta menos que 50. ",Robo," Cancelado para verificação");
		return; //testar depois.
	 }    
           
           
           */
           
    
	 
	 
   return(INIT_SUCCEEDED);
  }
  
void OnTick()
  {
    if (OrdersTotal()==0 && MarketInfo(Symbol(),MODE_SPREAD) >6)
    {
      Comment("Spread maior que 6. Aguardando!");
      return; //testar depois.
    }
  
//||||||||||||||||||||||||||||||||||||||||||||||||||||||CONFIGURAÇÃO DE LOTE|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

 if(AccountBalance()>Balancoanterior) //if(AccountBalance()>Balancoanterior/*+606+909+808*/)
 {                                    
    Lots1=defaultLot1;                       
    Lots2=defaultLot2;
    Lots3=defaultLot3;
 }
      static int closedOrders=0;
      if(OrdersHistoryTotal()!=closedOrders)
      {
         closedOrders=OrdersHistoryTotal();
         int hstTotal = OrdersHistoryTotal(); 
        
         if(OrderSelect(hstTotal-2,SELECT_BY_POS,MODE_HISTORY))
         if(OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber3)
         {
            if(OrderOpenPrice()<OrderClosePrice())
            {
              MAGIC3 = OrderCloseTime()+MinutesWait*60; 
              Balancoanterior = AccountBalance();
               
             Lots1=maxLots1;
             Lots2=maxLots2;
             Lots3=maxLots3;
            }
            
           
         } //FIM SELEÇÃO OP_SELL
         
         if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber3)
         {
            if(OrderOpenPrice()>OrderClosePrice())
            { 
               MAGIC3 = OrderCloseTime()+MinutesWait*60;
               Balancoanterior = AccountBalance();
               
               Lots1=maxLots1;
               Lots2=maxLots2;
               Lots3=maxLots3;
            }
          } //FIM SELEÇÃO OP_BUY        
         
      }//FIM ORDERHISTORYTOTAL()
      
      //========================POINT===============================
               double MyPoint=Point;                                      
               if(Digits==3 || Digits==5) MyPoint=Point*10;               
      //============================================================
      
     double BBupper = iBands(Symbol(),NULL,22,3,0,PRICE_CLOSE,MODE_UPPER,0);
     double BBlower = iBands(Symbol(),NULL,22,3,0,PRICE_CLOSE,MODE_LOWER,0);
     
      
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ABERTURA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++       
   if(TimeCurrent()>MAGIC3)
   {
   if(OrdersTotal()==0)
   {
      if(Ask > BBupper || Bid > BBupper )
      {
         ticket = OrderSend(Symbol(),OP_SELL,Lots1,Bid,Slippage,0,Bid-TAKE1*MyPoint,Robo,MagicNumber1,0,Red);
      }
      
      if(Bid < BBlower || Ask < BBlower)
      {
         ticket = OrderSend(Symbol(),OP_BUY,Lots1,Ask,Slippage,0,Ask+TAKE1*MyPoint,Robo,MagicNumber1,0,Blue);
      }      
 }
  }//FIM ORDERSTOTAL
  
  
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++CONFIGURAÇÃO DE ORDEM MAGIC 1++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
      if(OrdersTotal()==1)
      {
      int cnt, total=OrdersTotal();
      for(cnt=0;cnt<total;cnt++)
      {
         if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber1)
         {
           
                     
            if(OrderType()==OP_BUY)
            {  //DEFINIÇÃO DE STOP
               if(Ask+STOP1*MyPoint<OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_BUY,Lots2,Ask,Slippage,0,0,Robo,MagicNumber2,0,Blue);
            }//FIM OP_BUY
            
            
            if(OrderType()==OP_SELL)
            {  //DEFINIÇÃO DE STOP
               if(Bid-STOP1*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,Lots2,Bid,Slippage,0,0,Robo,MagicNumber2,0,Red);
            }//FIM OP_SELL      
            
            
         }//FIM ORDERMAGIC
      }//FIM CONTADOR      
      }      
               
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++CONFIGURAÇÃO DE ORDEM MAGIC 2++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
            
            if(OrdersTotal()==2)
            {
            int cntt, totalt=OrdersTotal();
            for(cntt=0;cntt<totalt;cntt++)
            {
               if(OrderSelect(cntt,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
               {
                  if(OrderType()==OP_SELL)
                  {  //DEFINIÇÃO DE TAKE
                     if(Bid+TAKE2*MyPoint<OrderOpenPrice()) bool TAKESHELL2=true;
                     
                     //DEFINIÇÃO DE STOP E ORDERSEND MAGIC3
                     if(Bid-STOP2*MyPoint>OrderOpenPrice()) ticket = OrderSend(Symbol(),OP_SELL,Lots3,Bid,Slippage,0,Bid-TAKE2*MyPoint,Robo,MagicNumber3,0,clrGreenYellow);
                      
                     
                  }
                  
                  if(OrderType()==OP_BUY)
                  {  //DEFINIÇÃO DE TAKE
                     if(Ask-TAKE2*MyPoint>OrderOpenPrice()) bool TAKEBUY2=true; 
                     
                     if(Ask+STOP2*MyPoint<OrderOpenPrice()) ticket =  OrderSend(Symbol(),OP_BUY,Lots3,Ask,Slippage,0,Ask+TAKE2*MyPoint,Robo,MagicNumber3,0,clrGreenYellow);

                  }
               
               }//FIM MAGIC2
             }//FIM CONTADOR
  
  }
  
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++CONFIGURAÇÃO MAGIC3++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
            
            int f, totalf=OrdersTotal();
            for(f=0;f<totalf;f++)
            {
               if(OrderSelect(f,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber3)
               {
                  if(OrderType()==OP_SELL)
                  {
                     if(Bid+TAKE3*MyPoint<OrderOpenPrice()) bool TAKESHELL3=true;
                     if(Bid-STOP3*MyPoint>OrderOpenPrice() ) bool STOPSHELL3=true;

                  }


                  if(OrderType()==OP_BUY)
                  {
                      if(Ask-TAKE3*MyPoint>OrderOpenPrice()) bool TAKEBUY3=true; 
                      if(Ask+STOP3*MyPoint<OrderOpenPrice() )bool STOPBUY3=true;
   
                  }    
                  
               }
            } 

 //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++FECHAMENTO DE TODAS AS ORDENS++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
          int v, totalv=OrdersTotal();
            for(v=0;v<totalv;v++)
            {
               if(OrderSelect(v,SELECT_BY_POS,MODE_TRADES))
               {
                 if( STOPSHELL3==true || STOPBUY3==true || TAKEBUY3==true || TAKESHELL3==true || TAKESHELL2==true || TAKEBUY2==true ) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                } 
           
            }//FIM CONTADOR  
  
  
   //POR ALGUM MOTIVO A ORDEM2 SO FECHA ABRINDO OUTRO CONTADOR.                
            int vx, totalvx=OrdersTotal();
            for(vx=0;vx<totalvx;vx++)
            {
               if(OrderSelect(vx,SELECT_BY_POS,MODE_TRADES))
               {
                  if(OrderMagicNumber()==MagicNumber2)
                  {
                        if( STOPSHELL3==true || STOPBUY3==true ||  TAKEBUY3==true || TAKESHELL3==true || TAKESHELL2==true || TAKEBUY2==true ) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                        
                  }//FIM ORDERMAGIC
               }//FIM ORDERSELECT
            }//FIM CONTADOR   
  
  }//FIM ONTICK
