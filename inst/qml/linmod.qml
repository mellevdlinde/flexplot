import QtQuick 2.8
import JASP.Controls 1.0
import JASP.Widgets 1.0
import JASP.Theme 1.0
Form 
{
  usesJaspResults: true

  VariablesForm
	{
    AvailableVariablesList { 
      name: "allVariables" 
    }
    AssignedVariablesList { 
			name: "dependent";	
			title: qsTr("Dependent Variable");
			singleVariable: true;
			allowedColumns: ["scale"]
		}
		AssignedVariablesList { 
		  id: vars
			name: "variables";	
			title: qsTr("Independent Variable(s)");
			singleVariable: false 
		}
  }

  ExpanderButton{
    title: qsTr("Model Terms");  
    enabled: vars.count > 1 
    VariablesForm
    {
      height: 150
      AvailableVariablesList { 
        name: "components"; 
        title: qsTr("Components"); 
        source: ["variables"]
      }
  
      AssignedVariablesList 
      { 
        name: "interactions"; 
        title: qsTr("Model terms"); 
        listViewType:"Interaction"
        ExtraControlColumn {
          type: "CheckBox"
          name: "polynoms"
          title: "Add as a polynomial"
        }
      }
    }
  }  
  
  ExpanderButton{
    title: qsTr("Visual Fitting")  
        DropDown{
	        name: "linetype"
	        values: ["Regression", "Quadratic", "Cubic"]
	        label: qsTr("Fitted line (scatterplots)")
	         enabled: vars.count > 0
        }
        
  }

  

  
		
  ExpanderButton{
    title: qsTr("Results Displays")

    Group{
    title: qsTr("Plots")
		  CheckBox{
			  name:"model"; 
			  label: qsTr("Model plot");
			  checked: true
			  }
      CheckBox{
			  name:"univariate"; 
			  label: qsTr("Univariate")
			  }
      CheckBox{
			  name:"residuals"; 
			  label: qsTr("Diagnostics")
			  }
      CheckBox{
			  name:"avp"; 
			  label: qsTr("Added variable plot");
			  enabled: vars.count > 1 
			  }			  
		  }
		  
		  
		Group{
    title: qsTr("Estimation")
      CheckBox{
			  name:"modinf"; 
			  label: qsTr("Show model comparisons");
			  enabled: vars.count > 1 			  
			}	
      CheckBox{
			  name:"means"; 
			  label: qsTr("Report means");
			  checked: true
			}	
      CheckBox{
			  name:"diff"; 
			  label: qsTr("Show mean differences")
			  checked: true
			}	
      CheckBox{
			  name:"sl"; 
			  label: qsTr("Show slopes/intercepts");
			  checked: true
			}		
      CheckBox{
			  name:"ci"; 
			  label: qsTr("Show 95% intervals");
			  checked: true
			}	 			
		}
	}
		
		  ExpanderButton
  {
      title: qsTr("Plot Controls")
      
        Group{
        title: qsTr("Point controls")
        columns: 4
		        Slider{
              name: "alpha"
              label: qsTr("Point transparency")
              value: 0.4
              vertical: true
              enabled: varlist.count > 0
            }
		        Slider{
              name: "jitx"
              label: qsTr("Jitter in X")
              value: .1
              min: 0
              max: .5
              vertical: true
              enabled: varlist.count > 0
            }  
		        Slider{
              name: "jity"
              label: qsTr("Jitter in Y")
              value: 0
              min: 0
              max: .5
              vertical: true
              enabled: varlist.count > 0
            }   
        }
        Group{
        title: qsTr("Aesthetics")
            DropDown{
			        name: "theme"
			        values: ["JASP", "Black and white", "Minimal", "Classic", "Dark"]
			        label: qsTr("GGplot theme")
		        }
		        CheckBox{
              name:"ghost"; 
              label: qsTr("Ghost lines");
              checked: true
              enabled: vars.count > 1 & vars.count< 4
            }  
        }

  }
  
  
}