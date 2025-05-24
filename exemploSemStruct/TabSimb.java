import java.util.ArrayList;
import java.util.Iterator;


public class TabSimb
{
    private ArrayList<TS_entry> lista;
    
    public TabSimb( )
    {
        lista = new ArrayList<TS_entry>();
    }
    
     public void insert( TS_entry nodo ) {
         lista.add(nodo);
    }    

    public void insert( TS_entry nodo, TS_entry escopo ) {
        if (escopo != null )
           escopo.getLocalTS().insert( nodo, null);        
        else
          lista.add(nodo);
    }        


    public void listar() {
      int cont = 0;  
      System.out.println("\n\nListagem da tabela de simbolos:\n");
      System.out.println("ident\t\tClasse\t\tEscopo\t\tTipo\n");
      for (TS_entry nodo : lista) {
          System.out.println(nodo);
      }
    }
      
    public TS_entry pesquisa(String umId, TS_entry escopo) {
      if (escopo != null && escopo.getLocalTS() != null) {
          TS_entry local = escopo.getLocalTS().pesquisa(umId, null);
          if (local != null) return local;
      }
      
      for (TS_entry nodo : lista) {
          if (nodo.getId().equals(umId)) {
              return nodo;
          }
      }
      return null;
    }
    // public TS_entry pesquisa(String umId) {
    //   for (TS_entry nodo : lista) {
    //       if (nodo.getId().equals(umId)) {
	  //     return nodo;
    //         }
    //   }
    //   return null;
    // }

    public  ArrayList<TS_entry> getLista() {return lista;}
}



