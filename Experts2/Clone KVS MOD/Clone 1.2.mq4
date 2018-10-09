/*========DESCRIÇÃO Clone 1.2======
1. duas ordens BUY e SHELL
2. se buy(MAGIC1) der take, envia a ordem SHELL(MAGIC2) até ela aguentar.
3. Se MAGIC2 der stop o MAGIC1 é encerrado e envia SHELL(MAGIC3) pra recuperar um pouco.

=======================*/


/*=======================================================ANOTAÇÕES GERAIS========================================================
IDENTIDO AO CLONE 1.1 POREM COM TRALLINGSTOP

*DANDO RESULTADO NEGATIVO. VOLTEI PARA O 1.1 PARA TENTAR SEGUIR EXATAMENTE COMO O KVS.
Eu preciso lucrar cara nesse EA sem ter muitas perdas assim como o KVS acontece. Porque eu so tenho +- 90 USD. se eu perder esse dinheiro
como vou seguir no mercado? éis a questão. =\
===============================================================================================================================*/

input int MagicNumber1=1001; 
input int MagicNumber2=1002;
input int MagicNumber3=1003;

input int MagicNumber4=1004;




input double Lots1=0.1;
input double Lots2=0.1;
input double Lots3=0.2;
input double Lots4=0.4;





input int oneTP = 40; //80 seria bom?
input int twooSP = 20;
input int twooTP = 20;

int ticket;

int OnInit(){return(INIT_SUCCEEDED);}
void OnDeinit(const int reason){}


void OnTick()
  {
            //=================POINT=====================================
            double MyPoint=Point;
            if(Digits==3 || Digits==5) MyPoint=Point*10;
            
            

//=======================================================================================================================================
//                                                          ENVIO DE ORDENS   
//ANOTAÇÕES:=============================================================================================================================
//
//     

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++PRIMEIRA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 


      if(OrdersTotal()==0)
      {
         ticket   =      OrderSend(Symbol(),OP_BUY,Lots1,Ask,0,0,Ask+oneTP*MyPoint,NULL,MagicNumber1,0,Blue);      
         ticket   =      OrderSend(Symbol(),OP_SELL,Lots1,Bid,0,0,Bid-oneTP*MyPoint,NULL,MagicNumber1,0,Red);
      }
      
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++SEGUNDA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

         if(OrdersTotal()==1)
         {
            int cnt, total=OrdersTotal();
            for(cnt=0;cnt<total;cnt++)
            {
               if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber1)
               {
      
                  if(OrderType()==OP_SELL)
                  {  
                     ticket = OrderSend(Symbol(),OP_SELL,Lots2,Bid,0,0,0,NULL,MagicNumber2,0,clrPink);      
                  }//FIM OP_SELL   
         
                  if(OrderType()==OP_BUY)
                  {
                     ticket = OrderSend(Symbol(),OP_BUY,Lots2,Ask,0,0,0,NULL,MagicNumber2,0,clrPink);
                  }//FIM OP_BUY
                  
               }//FIM OrderMagicNumber        
        
             }//Fim Contador
          }//FIM IF    

   
     


//=======================================================================================================================================
//                                                          FECHAMENTO DE ORDENS   
//ANOTAÇÕES:=============================================================================================================================
//
//             
            
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++SEGUNDA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++     
      int j, totalj=OrdersTotal();
      for(j=0;j<totalj;j++)
      {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber2)
         {
            if(OrderType()==OP_SELL)
            {  // if(Bid+twooTP*MyPoint<OrderOpenPrice()) bool TAKE2shell =  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
               double stnewpriceshell = OrderOpenPrice();
               double SLshell = OrderStopLoss();
               
               if(SLshell<=0 && Bid+20*MyPoint<stnewpriceshell)
               {
                  ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpriceshell-15*MyPoint,0,0,clrLightGreen); //trallingstop. encontrar os perfeitos pips
               }
               
               if(SLshell>0 && Bid+20*MyPoint<SLshell)
               {
                  ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLshell-15*MyPoint,0,0,clrLightGreen); //trallingstop. encontrar os perfeitos pips
               }
               
               else if(Bid-twooSP*MyPoint>OrderOpenPrice())  bool STOP2shell = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
               
               
               if(STOP2shell==true) bool SEND3shell = OrderSend(Symbol(),OP_SELL,Lots3,Bid,0,0,0,NULL,MagicNumber3,0,clrPink); //ENVIO ORDEM3.
            
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {//Mantem o STOP e o TAKE é tralling stop.  if(Ask-twooTP*MyPoint>OrderOpenPrice()) bool TAKE2buy = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
                
                double stnewpricebuy = OrderOpenPrice();
                double SLbuy = OrderStopLoss(); 
                
                
                if(SLbuy<=0 && Ask-20*MyPoint>stnewpricebuy)
                {
                  ticket = OrderModify(OrderTicket(),OrderOpenPrice(),stnewpricebuy+15*MyPoint,0,0,clrLightGreen); //trallingstop. encontrar os perfeitos pips
                }
                
                if(SLbuy>0 && Ask-20*MyPoint>SLbuy)
                {
                  ticket = OrderModify(OrderTicket(),OrderOpenPrice(),SLbuy+15*MyPoint,0,0,clrLightGreen); //trallingstop. encontrar os perfeitos pips
                }

    /*STOP */   else if(Ask+twooSP*MyPoint<OrderOpenPrice()) bool STOP2buy = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); 
            
                if(STOP2buy==true) bool SEND3buy = OrderSend(Symbol(),OP_BUY,Lots3,Ask,0,0,0,NULL,MagicNumber3,0,clrPink); //ENVIO ORDEM3.
            
            }
               
         }//FIM MAGIC
      }//FIM CONTADOR         
     
 //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TERCEIRA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++       
      
      int x, totalx=OrdersTotal();
      for(x=0;x<totalx;x++)
      {
         if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber3)
         {
            if(OrderType()==OP_BUY)
            {  
              if(Ask-10*MyPoint>OrderOpenPrice()) bool TAKE3buy = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
              
              if(Ask+10*MyPoint<OrderOpenPrice()) bool STOP3buy = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
              
              if(STOP3buy==true) ticket = OrderSend(Symbol(),OP_SELL,Lots4,Bid,0,Bid+10*MyPoint,Bid-10*MyPoint,NULL,MagicNumber4,0,Red);
              //SERÁ QUE SERIA LEGAL UM TRALLING STOP no magic4??
                
            }//FIM OP_BUY
            
         if(OrderType()==OP_SELL)
         {
           if(Bid+10*MyPoint<OrderOpenPrice()) bool TAKE3shell = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
           
           if(Bid-twooSP*MyPoint>OrderOpenPrice()) bool STOP3shell = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
           
           if(STOP3shell==true) ticket = OrderSend(Symbol(),OP_BUY,Lots4,Ask,0,Ask-10*MyPoint,Ask+10*MyPoint,NULL,MagicNumber4,0,clrPink);
         
         }//FIM OP_SELL
         
            
         }//FIM MAGIC3
      }//FIM CONTADOR   
                         
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++PRIMEIRA ORDEM++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

    int r, totalr=OrdersTotal();
      for(r=0;r<totalr;r++)
      {
         if(OrderSelect(r,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber1)
         {
            if(OrderType()==OP_SELL)
            {
               if(STOP2shell==true) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); 
            }
            
            if(OrderType()==OP_BUY)
            {
               if(STOP2buy==true) ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
               
            }
            }}   
    
    
        
   }//FIM OnTick()
//+------------------------------------------------------------------+

