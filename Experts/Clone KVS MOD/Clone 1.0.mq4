/*========DESCRIÇÃO Clone 1.3======


=======================*/


/*=======================================================ANOTAÇÕES GERAIS========================================================
Começar do zero. tem que ser IGUAL, EXATAMENTE IGUAL ao KV S MOD.

onetp=80. resultado satisfatorio. mas onetp=40 nao =\\\\\
===============================================================================================================================*/

input int MagicNumber1=1001; 
input int MagicNumber2=1002;
input int MagicNumber3=1003;





input double Lots1=0.01;
input double Lots2=0.01;
input double Lots3=0.01;





input int oneTP = 80;
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
            {     
               if(Bid+twooTP*MyPoint<OrderOpenPrice()) bool TAKE2shell =  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
         
               if(Bid-twooSP*MyPoint>OrderOpenPrice())  bool STOP2shell = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
               
               
               if(STOP2shell==true) bool SEND3buy = OrderSend(Symbol(),OP_SELL,Lots3,Bid,0,Bid+10*MyPoint,Bid-10*MyPoint,NULL,MagicNumber3,0,clrPink);
            
            }//FIM OP_SELL
            
            if(OrderType()==OP_BUY)
            {
                if(Ask-twooTP*MyPoint>OrderOpenPrice()) bool TAKE2buy = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); 
               
                if(Ask+twooSP*MyPoint<OrderOpenPrice()) bool STOP2buy = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); 
            
                if(STOP2buy==true) bool SEND3shell = OrderSend(Symbol(),OP_BUY,Lots3,Ask,0,Ask-10*MyPoint,Ask+10*MyPoint,NULL,MagicNumber3,0,clrPink);
            
            }
               
         }//FIM MAGIC
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
               if( STOP2shell==true) ticket =OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink); 
            }
            
            if(OrderType()==OP_BUY)
            {
               if(STOP2buy==true) ticket =    OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrPink);
               
            }
            }}   
    
    
        
   }//FIM OnTick()
//+------------------------------------------------------------------+

