S E T   A N S I _ N U L L S   O N  
 G O  
 S E T   Q U O T E D _ I D E N T I F I E R   O N  
 G O  
 C R E A T E   P R O C   [ d b o ] . [ d b a _ S p a c e U s e d ]    
  
         @ S o u r c e D B   v a r c h a r   (   1 2 8   )   =   n u l l   - -   O p t i o n a l   d a t a b a s e   n a m e  
                   - -   I f   o m i t t e d ,   t h e   c u r r e n t   d a t a b a s e   i s   r e p o r t e d .  
     ,   @ S o r t B y   c h a r ( 1 )   =   ' S '   - -   N   f o r   n a m e ,   S   f o r   S i z e  
                       - -   T   f o r   t a b l e   n a m e  
  
 / *   R e t u r n s   a   t a b l e   w i t h   t h e   s p a c e   u s e d   i n   a l l   t a b l e s   o f   t h e  
 *     d a t a b a s e .     I t ' s   r e p o r t e d   w i t h   t h e   s c h e m a   i n f o r m a t i o n   u n l i k e  
 *     t h e   s y s t e m   p r o c e d u r e   s p _ s p a c e u s e .  
 *  
 *     s p _ s p a c e u s e d   i s   u s e d   t o   p e r f o r m   t h e   c a l c u l a t i o n s   t o   e n s u r e  
 *     t h a t   t h e   n u m b e r s   m a t c h   w h a t   S Q L   S e r v e r   w o u l d   r e p o r t .  
 *  
 *     C o m p a t i b l e   w i t h   s Q L   S e r v e r   2 0 0 0   a n d   2 0 0 5  
 *  
 *   E x a m p l e :  
 e x e c   d b o . d b a _ S p a c e U s e d   n u l l ,   ' N '  
 *  
 *   �   C o p y r i g h t   2 0 0 7   A n d r e w   N o v i c k   h t t p : / / w w w . N o v i c k S o f t w a r e . c o m  
 *   T h i s   s o f t w a r e   i s   p r o v i d e d   a s   i s   w i t h o u t   w a r r e n t e e   o f   a n y   k i n d .  
 *   Y o u   m a y   u s e   t h i s   p r o c e d u r e   i n   a n y   o f   y o u r   S Q L   S e r v e r   d a t a b a s e s  
 *   i n c l u d i n g   d a t a b a s e s   t h a t   y o u   s e l l ,   s o   l o n g   a s   t h e y   c o n t a i n    
 *   o t h e r   u n r e l a t e d   d a t a b a s e   o b j e c t s .   Y o u   m a y   n o t   p u b l i s h   t h i s    
 *   p r o c e d u r e   e i t h e r   i n   p r i n t   o r   e l e c t r o n i c a l l y .  
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /  
 A S  
  
 S E T   N O C O U N T   O N  
  
 D E C L A R E   @ s q l   n v a r c h a r   ( 4 0 0 0 )  
  
 I F   @ S o u r c e D B   I S   N U L L   B E G I N  
 	 S E T   @ S o u r c e D B   =   D B _ N A M E   ( )   - -   T h e   c u r r e n t   D B    
 E N D  
  
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
 - -   C r e a t e   a n d   f i l l   a   l i s t   o f   t h e   t a b l e s   i n   t h e   d a t a b a s e .  
  
 C R E A T E   T A B L E   # T a b l e s   ( 	 [ s c h e m a ]   s y s n a m e  
                                             ,   T a b N a m e   s y s n a m e   )  
 	 	  
 S E L E C T   @ s q l   =   ' i n s e r t   # t a b l e s   ( [ s c h e m a ] ,   [ T a b N a m e ] )    
                                     s e l e c t   T A B L E _ S C H E M A ,   T A B L E _ N A M E    
 	 	                     f r o m   [ ' +   @ S o u r c e D B   + ' ] . I N F O R M A T I O N _ S C H E M A . T A B L E S  
 	 	 	                     w h e r e   T A B L E _ T Y P E   =   ' ' B A S E   T A B L E ' ' '  
 E X E C   ( @ s q l )  
  
  
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
 - -   # T a b S p a c e T x t   H o l d s   t h e   r e s u l t s   o f   s p _ s p a c e u s e d .    
 - -   I t   D o e s n ' t   h a v e   S c h e m a   I n f o !  
 C R E A T E   T A B L E   # T a b S p a c e T x t   (  
                                                   T a b N a m e   s y s n a m e  
 	                                       ,   [ R o w s ]   v a r c h a r   ( 1 1 )  
 	                                       ,   R e s e r v e d   v a r c h a r   ( 1 8 )  
 	 	 	 	 	       ,   D a t a   v a r c h a r   ( 1 8 )  
 	                                       ,   I n d e x _ S i z e   v a r c h a r   (   1 8   )  
 	                                       ,   U n u s e d   v a r c h a r   (   1 8   )  
                                               )  
 	 	 	 	 	  
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
 - -   T h e   r e s u l t   t a b l e ,   w i t h   n u m e r i c   r e s u l t s   a n d   S c h e m a   n a m e .  
 C R E A T E   T A B L E   # T a b S p a c e   (   [ S c h e m a ]   s y s n a m e  
                                               ,   T a b N a m e   s y s n a m e  
 	                                       ,   [ R o w s ]   b i g i n t  
 	                                       ,   R e s e r v e d M B   n u m e r i c ( 1 8 , 3 )  
 	 	 	 	 	       ,   D a t a M B   n u m e r i c ( 1 8 , 3 )  
 	                                       ,   I n d e x _ S i z e M B   n u m e r i c ( 1 8 , 3 )  
 	                                       ,   U n u s e d M B   n u m e r i c ( 1 8 , 3 )  
                                               )  
  
 D E C L A R E   @ T a b   s y s n a m e   - -   t a b l e   n a m e  
             ,   @ S c h   s y s n a m e   - -   o w n e r , s c h e m a  
  
 D E C L A R E   T a b l e C u r s o r   C U R S O R   F O R  
         S E L E C T   [ S C H E M A ] ,   T a b N A M E    
                   F R O M   # t a b l e s  
  
 O P E N   T a b l e C u r s o r ;  
 F E T C H   T a b l e C u r s o r   i n t o   @ S c h ,   @ T a b ;  
  
 W H I L E   @ @ F E T C H _ S T A T U S   =   0   B E G I N  
  
 	 S E L E C T   @ s q l   =   ' e x e c   [ '   +   @ S o u r c e D B    
 	       +   ' ] . . s p _ e x e c u t e s q l   N ' ' i n s e r t   # T a b S p a c e T x t   e x e c   s p _ s p a c e u s e d   '  
 	       +   ' ' ' ' ' [ '   +   @ S c h   +   ' ] . [ '   +   @ T a b   +   ' ] '   +   ' ' ' ' ' ' ' ' ;  
  
 	 D e l e t e   f r o m   # T a b S p a c e T x t ;   - -   S t o r e s   1   r e s u l t   a t   a   t i m e  
 	 E X E C   ( @ s q l ) ;  
  
         I N S E R T   I N T O   # T a b S p a c e  
 	 S E L E C T   @ S c h  
 	           ,   [ T a b N a m e ]  
                   ,   c o n v e r t ( b i g i n t ,   r o w s )  
 	           ,   c o n v e r t ( n u m e r i c ( 1 8 , 3 ) ,   c o n v e r t ( n u m e r i c ( 1 8 , 3 ) ,    
 	 	                 l e f t ( r e s e r v e d ,   l e n ( r e s e r v e d ) - 3 ) )   /   1 0 2 4 . 0 )    
                                 R e s e r v e d M B  
 	           ,   c o n v e r t ( n u m e r i c ( 1 8 , 3 ) ,   c o n v e r t ( n u m e r i c ( 1 8 , 3 ) ,    
 	 	                 l e f t ( d a t a ,   l e n ( d a t a ) - 3 ) )   /   1 0 2 4 . 0 )   D a t a M B  
 	           ,   c o n v e r t ( n u m e r i c ( 1 8 , 3 ) ,   c o n v e r t ( n u m e r i c ( 1 8 , 3 ) ,    
 	 	                 l e f t ( i n d e x _ s i z e ,   l e n ( i n d e x _ s i z e ) - 3 ) )   /   1 0 2 4 . 0 )    
                                   I n d e x _ S i z e M B  
 	           ,   c o n v e r t ( n u m e r i c ( 1 8 , 3 ) ,   c o n v e r t ( n u m e r i c ( 1 8 , 3 ) ,    
 	 	                 l e f t ( u n u s e d ,   l e n ( [ U n u s e d ] ) - 3 ) )   /   1 0 2 4 . 0 )    
                                 [ U n u s e d M B ]  
                 F R O M   # T a b S p a c e T x t ;  
  
 	 F E T C H   T a b l e C u r s o r   i n t o   @ S c h ,   @ T a b ;  
 E N D ;  
  
 C L O S E   T a b l e C u r s o r ;  
 D E A L L O C A T E   T a b l e C u r s o r ;  
  
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
 - -   C a l l e r   s p e c i f i e s   s o r t ,   D e f a u l t   i s   s i z e  
 I F   @ S o r t B y   =   ' N '   - -   U s e   S c h e m a   t h e n   T a b l e   N a m e  
 	 S E L E C T   *   F R O M   # T a b S p a c e  
 	       O R D E R   B Y   [ S c h e m a ]   a s c ,   [ T a b N a m e ]   a s c  
 E L S E   I F   @ S o r t B y   =   ' T '     - -   T a b l e   n a m e ,   t h e n   s c h e m a  
 	 S E L E C T   *   F R O M   # T a b S p a c e  
 	       O R D E R   B Y   [ T a b N a m e ]   a s c ,   [ S c h e m a ]   a s c  
 E L S E     - -   S ,   N U L L ,   o r   w h a t e v e r   g e t ' s   t h e   d e f a u l t  
 	 S E L E C T   *   F R O M   # T a b S p a c e  
 	       O R D E R   B Y   R e s e r v e d M B   d e s c  
 ;  
  
 D R O P   T A B L E   # T a b l e s  
 D R O P   T A B L E   # T a b S p a c e T x t  
 D R O P   T A B L E   # T a b S p a c e  
  
 