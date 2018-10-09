
/*=======================================================ANOTAÇÕES========================================================
Realizar TODOS OS TESTES no demo.
quando tiver absoluta certeza lançar na conta real. acredito que so segunda.
QUINTA TEM BREXIT.


*verificar se funciona no USDJPY.
verificar a retirada do MyPoint. e deixaxr so em PONTOS.

========================================================================================================================*/


static input string Option1 = "------- Configurações Basicas";
extern int StopLoss = 10;

static input string Option2 = "--------Configurações TrallingStop";
extern int TrallingStop =20;
extern int RetirarPips = 6;


static input string Option4 = "--------Outras Opções";
extern int MinuteFinish = 80; //encerrar ordem pendente


string Robo = "SemiAutomatico";
int ticket;
double Spread = MarketInfo(Symbol(),MODE_SPREAD);

bool Order2,countsellFINISH,countbuyFINISH;

int OnInit(){return(INIT_SUCCEEDED);}

void OnTick()
{        

  Comment(  "\n\n",
            "    Olá João, Operando com o Robo  ",Robo,"\n",
            "   ......................................................................","\n\n",
            
            "    Moeda           ","        ",Symbol(),"\n",
            
            "   ......................................................................","\n\n",

         ); 
      
//=========================POINT
      double MyPoint=Point;                                      
      if(Digits==3 || Digits==5) MyPoint=Point*10;   
   
//++++++++++++++++++++++++++++++++++++++++++++++++++ENCERRAR ORDENS PENDENTES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                                      

    for (int trade7=OrdersTotal()-1; trade7>=0; trade7--) 
   {
      if (OrderSelect(trade7,SELECT_BY_POS, MODE_TRADES)) 
      {
          if(OrderType()==OP_BUYSTOP)
          {   
             if(OrderOpenTime()<Time[0]-MinuteFinish*60 ) ticket = OrderDelete(OrderTicket(),Green);  
          }//FIM OP_BUYSTOP
         
          if(OrderType()==OP_SELLSTOP)
          {  
             if(OrderOpenTime()<Time[0]-MinuteFinish*60) ticket = OrderDelete(OrderTicket(),Green); 
          }//FIM OP_SELLSTOP       
         
      }//FIM ORDERSELECT
    }//FIM CONTADOR
    
               
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++TRALLING STOP+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
  
    for (int trade3=OrdersTotal()-1; trade3>=0; trade3--) 
    {
      if (OrderSelect(trade3,SELECT_BY_POS, MODE_TRADES)) 
      {
         if(OrderType()==OP_BUY)
         {
            double stnewpricebuy = OrderOpenPrice();
            double SL = OrderStopLoss();
              
            if(SL==0) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-StopLoss*MyPoint,0,0,clrLightGreen);
            if(SL>0 && (Bid>OrderStopLoss()+TrallingStop*MyPoint))   ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()+(TrallingStop-RetirarPips)*MyPoint,0,0,clrLightGreen);
               
         }//FIM OP_BUY  
   
         if(OrderType()==OP_SELL)
         { 
           double stnewpricesell = OrderOpenPrice();
           double SLsell = OrderStopLoss();
              
           if(SLsell==0) ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+StopLoss*MyPoint,0,0,clrLightGreen);         
           if(SLsell>0 && (Ask<OrderStopLoss()-TrallingStop*MyPoint))  ticket = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss()-(TrallingStop-RetirarPips)*MyPoint,0,0,clrLightGreen);
         }//FIM OP_SELL
              
     }//FIM SELECT
   }//FIM CONTADOR  

//=========================CONTADOR DE ORDENS ABERTAS  
  
   bool countsellstop,countbuystop,countsell,countbuy;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) 
   {
      int a = OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);

         if (OrderType() == OP_SELLSTOP) countsellstop=true; 
         if (OrderType() == OP_BUYSTOP) countbuystop=true; 
         if (OrderType() == OP_SELL) countsell=true; 
         if (OrderType() == OP_BUY) countbuy=true;   
   }//FIM CONTADOR

 
////SE 2 ORDENS ABERTA quando ativa uma a outra fecha.

   if(OrdersTotal()==0){ Order2=false;countbuyFINISH=false;countsellFINISH=false; }
      
   if(countbuystop==true && countsellstop==true) Order2=true;
                
   if(Order2==true)
   {
      if(countbuystop==true && countsellstop==false) countbuyFINISH  = true;    
      if(countbuystop==false && countsellstop==true) countsellFINISH = true;
   }
   
//EXCLUSAO.   
   for (int trade733=OrdersTotal()-1; trade733>=0; trade733--) 
   {
      if(OrderSelect(trade733,SELECT_BY_POS, MODE_TRADES)) 
      {  
         if(OrderType()==OP_BUYSTOP)
         {   
             if(countbuyFINISH==true) ticket = OrderDelete(OrderTicket(),Green);  
         }
            
      }//FIM BUYSTOP
            
        if(OrderType()==OP_SELLSTOP)
        {  
           if(countsellFINISH==true) ticket = OrderDelete(OrderTicket(),Green); 
        }//FIM OP_SELLSTOP       
         
         
     
  }//FIM CONTADOR
   
  
               
  }//FIM ONTICK
 