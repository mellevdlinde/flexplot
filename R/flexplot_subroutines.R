flexplot_errors = function(variables, data, method=method, axis){
  if (!all(variables %in% names(data))){
    not.there = variables[which(!(variables %in% names(data)))]
    stop(paste0("Ru oh! Somebody done made a mistake! Looks like you either spelled something wrong, or included a variable not in your dataset! Have you considered spellcheck? (Oh, btw, it was the variable(s) ", paste0(not.there, collapse=","), " that caused a problem"))
  }
  
  #### make sure all names are in the dataset
  if (!all(variables %in% names(data))){
    not.there = variables[which(!(variables %in% names(data)))]
    stop(paste0("So...we've got a lil' problem. You specified one or more variable in the formula that is not in your dataset (specifically ", paste0(not.there, collapse=", "), "). Let's get that fixed and try again.\n"))
  }

  #### give an error if they try to visualize logistic with a categorical x axis
  if (method=="logistic" & length(variables)>0){
    if (!is.numeric(data[,axis[1]])){
      stop(paste0("\nOh wise user of flexplot, you have encountered one of the FEW limitations of flexplot. Sorry, but you cannot plot a logistic curve when a categorical variable is on the x-axis. Sorry! Either remove the logistic request or put a numeric variable on the x axis. \n
				Best of luck on your statistical journeys."))
    }	
  } 
  
  if (is.null(data)){
    stop("Howdy! Looks like you forgot to include a dataset! Kinda hard to plot something with no data. Or so I've heard. What do I know? I'm just a computer. ")
  }
}

  #### this function figures out which variables need to be binned
#expect_identical(flexplot_break_me(exercise_data, c("muscle.gain", "income"), given="income"), "income")
#expect_identical(flexplot_break_me(exercise_data, c("weight.loss", "income"), given="income"), "income")
#expect_equal(length(flexplot_break_me(exercise_data, c("weight.loss", "income"), given=NULL)), 0)
#expect_equal(length(flexplot_break_me(exercise_data, c("weight.loss", "income", "weight.loss", "motivation", "therapy.type"), given=c("weight.loss", "motivation"))), 2)
flexplot_break_me = function(data, predictors, given){

  ### without this line of code, there's an error for those situations where there is no second axis
  if (length(axis)<2){
    second.axis = NA
  } else {
    second.axis = axis[2]
  }

  #### get the breaks for the needed variables (remove axis 1 because it's the axis and thus will never be binned)
  #### also, lapply fails when there's just one additional predictor, hence the if statement
  if (length(predictors)>2){
    break.me = predictors[-1][unlist(lapply(data[,predictors[-1]], FUN=is.numeric)) & ((predictors[-1] %in% given) | (second.axis %in% predictors[-1]))]	
  } else {
    break.me = predictors[-1][is.numeric(data[,predictors[-1]]) & ((predictors[-1] %in% given) | (second.axis %in% predictors[-1]))]	
  }
  
  #if (length(break.me)==0) break.me = NA
  return(break.me)
}


#flexplot_create_breaks(c("weight.loss", "motivation"), breaks=NULL, data, labels=NULL)
#flexplot_create_breaks(c("weight.loss", "motivation"), breaks=list(weight.loss=c(30, 70)), data, labels=NULL)
#flexplot_create_breaks(NULL, breaks=list(weight.loss=c(30, 70)), data, labels=NULL)
#expect_error(flexplot_create_breaks(break.me = c("weight.loss", "motivation"), breaks=c(30,70), data = data, labels=NULL))
#expect_error(flexplot_create_breaks(break.me = c("weight.loss", "motivation"), breaks=list(weightloss = c(30,70)), data = data, labels=NULL))
#flexplot_create_breaks(break.me = c("weight.loss", "motivation"), breaks=list(weight.loss = c(30)), data = data, labels=list(weight.loss = c("low", "high")))
# This function creates the breaks for the binning
flexplot_create_breaks = function(break.me, breaks, data, labels, bins=3){

  #### did they provide the breaks?
  if (!is.null(breaks)) {
    named.breaks = names(breaks)
  } else {
    named.breaks = NA
  }	
  
  #### create a list of breaks
  if (length(break.me)>0){
    
    #### bark at them if they forgot to name their breaks
    if (is.null(named.breaks)){	
      stop("You must name your breaks if you provide them. Be sure to do that. (e.g., breaks = list(variable1=c(5, 10, 15)), variable2=c(0,1,2))")
      
      #### make sure they spelled breaks right and such
    } else if (!is.na(named.breaks) & !(named.breaks %in% break.me)){
      stop("I can't find ", named.breaks, " in your list of variables to be binned (", paste0(break.me, collapse=","), "). Did you spell everything right?")
    }
    
    #### make an empty list if they don't provide breaks
    if (is.null(breaks)){
      breaks = rep(list(NULL),length(break.me))
    }
    
    #### now make the breaks and convert the data
    for (i in 1:length(break.me)){
      
      #### figure out how many bins there are
      if (length(names(labels)) >= i){
        if (length(labels[[i]])>=i){
          bins = length(labels[[i]])
        } else {
          bins = 3
        }
      } else {
        bins = 3
      }
      
		
      breaks[[i]] = prep.breaks(variable=break.me[i], data, breaks=breaks[[break.me[i]]], bins)
    }
  } else {
    breaks = NULL
  }
  if (length(breaks)>0)  names(breaks) = break.me
  
  return(breaks)
}


#flexplot_axis_given(formula(y~1))
flexplot_axis_given = function(formula){
  given = unlist(subsetString(as.character(formula)[3], sep=" | ", position=2, flexible=F))
  given = gsub(" ", "", given)		
  given = unlist(strsplit(given, "+", fixed=T))	
  axis = unlist(subsetString(as.character(formula)[3], sep=" | ", position=1, flexible=F))
  axis = gsub(" ", "", axis)			
  axis = unlist(strsplit(axis, "+", fixed=T))	
  list(given=given, axis=axis)
}

flexplot_delete_na = function(data, predictors, variables){
  if (length(predictors)>0){
    if (length(unlist(apply(data[,variables], 2, function(x){(which(is.na(x)))})))>0){
      delete.me = as.numeric(unlist(apply(data[,variables], 2, function(x){(which(is.na(x)))})))
      data = data[-delete.me,]
      return(data)
    } else {
      return(data)
    }
  } else {
    return(data)
  }
}


#expect_true(is.ordered(flexplot_convert_to_categorical(data %>% mutate(gender = as.numeric(gender)), "gender")$gender))
#expect_true(is.ordered(flexplot_convert_to_categorical(data %>% mutate(gender = as.numeric(gender)), c("therapy.type", "gender"))$gender))
#expect_false(is.ordered(flexplot_convert_to_categorical(data, axis=NULL)$gender))
flexplot_convert_to_categorical = function(data, axis){
  #### if they only have a few levels on the x axis, convert it to categorical
  if (length(axis)>0 & axis[1] != "1"){
    if (is.numeric(data[,axis[1]]) & length(unique(data[,axis[1]]))<5){
      data[,axis[1]] = factor(data[,axis[1]], ordered=T)
    }
    
    ### do the same for the second axis
    if (length(axis)>1){
      if (is.numeric(data[,axis[2]]) & length(unique(data[,axis[2]]))<5){
        data[,axis[2]] = factor(data[,axis[2]], ordered=T)
      }		
    }
  }
  return(data)
}


flexplot_bivariate_plot = function(outcome, predictors, axis, related, labels, bins, breaks, data, jitter=jitter, suppress_smooth=suppress_smooth, method=method, spread=spread, alpha=alpha, prediction=prediction){
  if (length(outcome)==1 & length(predictors)==0){
    
    ##### reorder according to columns lengths (if it's not an ordered factor)
    if (!is.numeric(data[,outcome]) & !is.ordered(data[,outcome])){
      counts = sort(table(data[,outcome]), decreasing=T)
      names(counts)
      data[,outcome] = factor(data[,outcome], levels=names(counts))
    }
    
    
    ### figure out how many levels for the variable
    levels = length(unique(data[,outcome]))	
    
    #### if numeric, do a histogram
    if (is.numeric(data[,outcome])){
      p = 'ggplot(data=data, aes_string(outcome)) + geom_histogram(fill="lightgray", col="black", bins=min(30, round(levels/2))) + theme_bw() + labs(x=outcome)'
    } else {
      p = 'ggplot(data=data, aes_string(outcome)) + geom_bar() + theme_bw() + labs(x= outcome)'		
    } 
    points = "xxxx"
    fitted = "xxxx"		
    
    ### BIVARIATE PLOTS
  } else if (length(outcome)==1 & length(axis)==1 & !related){
    
    #### if both are categorical, do chi square
    if (!is.numeric(data[[outcome]]) & !is.numeric(data[[axis]])){
      
      m = as.data.frame(table(data[,axis], data[,outcome])); names(m)[1:2] = c(axis, outcome)
      chi = chisq.test(data[,axis], data[,outcome])
      obs.exp = (chi$observed - chi$expected)/chi$expected
      m$Freq = as.vector(obs.exp)
      names(m)[names(m)=="Freq"] = "Proportion"
      data = m
      p = "ggplot(data=data, aes_string(x=axis, y='Proportion', fill=outcome)) + geom_bar(stat='identity', position='dodge') + theme_bw()"
      points = "xxxx"
      fitted = "xxxx"
    } else {
      
      ### reorder axis and alter default alpha if categorical
      if (!is.numeric(data[,axis])){
        
        #### reorder if it's not already ordered
        if (!is.ordered(data[, axis[1]])){
          if (spread=="quartiles"){ fn = "median"} else {fn = "mean"}
          ord = aggregate(data[,outcome]~data[, axis], FUN=fn, na.rm=T)
          ord = ord[order(ord[,2], decreasing=T),]
          data[,axis] = factor(data[, axis], levels=ord[,1])
        }
        
        #### set default alpha
        if(alpha==.99977){
          alpha = .2
        }		
      }
      
      p = 'ggplot(data=data, aes_string(x=axis, y=outcome))'
      points = points.func(axis.var=axis, data=data, jitter=jitter)
      fitted = fit.function(outcome, axis, data=data, suppress_smooth=suppress_smooth, method=method, spread=spread)		
      
    }	
    
    ### RELATED T-TEST
  } else if (related){		
    
    
    #### extract levels of the predictors
    levs = levels(data[,axis[1]])
    
    #### create difference scores
    g1 = data[data[, axis[1]]==levs[1], outcome]
    g2 = data[data[, axis[1]]==levs[2], outcome]				
    
    
    ### error checking
    if (length(predictors)!=1){
      stop("Currently, the 'related' option is only available when there's a single predictor.")
    } 
    
    if (length(levs)!=2){
      stop("Sorry, I can only accept two levels of the grouping variable when related=T.")
    }
    
    if (length(g1) != length(g2)){
      stop("Sorry, the length of the two groups are not the same. I can only create difference scores when the group sizes are identical.")
    }
    
    lab = paste0("Difference (",levs[2], "-", levs[1], ')')
    data = data.frame(Difference=g2-g1)
    data[[outcome]] = NA
    data[[predictors]] = NA
    
    
    p = paste0("ggplot(data, aes(y=Difference, x=1)) + theme_bw()+ geom_hline(yintercept=0, col='lightgray') + labs(x='Difference (", 
               levs[2], "-", levs[1], ")') + theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())")
    
    #### modify default jitter
    if (is.null(jitter)){
      jitter = c(.05, 0)
    } 
    points = points.func(axis.var="Difference", data=data, jitter=jitter)
    fitted = paste0(fit.function(outcome, "Difference", data=data, suppress_smooth=suppress_smooth, method=method, spread=spread, categorical=T), " + coord_cartesian(xlim=c(.75, 1.25))")
    
    ##### if they have two axis variables
  } else if (length(axis)>1){
    
    #### if the second variable is numeric, bin it
    if (is.numeric(data[,axis[2]])){
      binned.name = paste0(axis[2], "_binned")
      data[[binned.name]] = bin.me(axis[2], data, bins, unlist(labels), breaks[[axis[2]]])
      axis[2] = binned.name
    }
    
    ### if they supply predictions, do not vary color
    if (!is.null(prediction)){
      p = 'ggplot(data=data, aes_string(x=predictors[1], y=outcome, color=axis[2], shape=axis[2])) + labs(color= axis[2], shape= axis[2])'
      
    } else {
      p = 'ggplot(data=data, aes_string(x=predictors[1], y=outcome, color=axis[2], linetype = axis[2], shape=axis[2])) + labs(color= axis[2], linetype= axis[2], shape= axis[2])'
      ### remove the default color if they have categorical variables		
    }
    
    points = points.func(axis.var=axis, data=data, jitter=jitter)
    fitted = fit.function(outcome, predictors=axis[1], data=data, suppress_smooth=suppress_smooth, method=method, spread=spread, mean.line=TRUE)
    
    
    ### remove the default color if they have something in the second axis
    if (!is.numeric(data[,axis[2]])){
      fitted = gsub(", color = '#bf0303'", "", fitted, fixed=T)
      fitted = gsub(', color = "#bf0303"', "", fitted, fixed=T)
    }	
  }
  
  list(p=p, points=points, fitted=fitted, prediction=prediction, data=data, alpha = alpha)
}


#### flexplot function for paneling
flexplot_panel_variables = function(outcome, predictors, axis, given, related, labels, bins, breaks, data, suppress_smooth=suppress_smooth, method=method, spread=spread, prediction, break.me){

  if (!is.na(given[1])){
    for (i in 1:length(given)){
      
      binned.name = paste0(given[i], "_binned")
      
      if (is.numeric(data[,given[i]])){
        b = bin.me(variable=given[i], data, bins, labels=labels[i], breaks=breaks[[given[i]]])
        #### if there's only one category, fix that succa!
        if (length(levels(b))==1 & length(unique(data[[given[i]]]))>1){
          data[,binned.name] = factor(data[,given[i]])
        } else {
          data[,binned.name] = b  
        }
        
        
        ### if they specified prediction, bin those too
        if (!is.null(prediction)){
          prediction[,binned.name] = bin.me(given[i], prediction, bins, labels[i], breaks[[given[i]]])
        }				
        ### reorder levels of bin 2
        if (i==2){
          data[,binned.name] = forcats::fct_rev(data[,binned.name])
        }
      } else {
        ### duplicate categorical variables and give a new name for binned ones
        data[,binned.name] = data[,given[i]]
        
        
        ### if they specified prediction, bin those too (because later when doing ghost lines, I randomly choose a prediction value from a data value, and they need to be binned before that)
        if (!is.null(prediction)){
          prediction[,binned.name] = prediction[,given[i]]
        }					
      }
    }
    
    #### prep the given variables to be stringed together
    given2 = given
    if (length(break.me)>0){
      given2[given2%in%break.me] = paste0(given2[given2%in%break.me], "_binned")
    }	
    given.as.string = ifelse(length(given)>1 & !is.na(given2[1]),paste0(rev(given2), collapse="~"), paste0("~",given2))
    

    facets = paste0('facet_grid(as.formula(', given.as.string, '),labeller = custom.labeler)')			
  } else {
    facets = "xxxx"
  }
  
  list(facets=facets, prediction=prediction, data=data)
}


#