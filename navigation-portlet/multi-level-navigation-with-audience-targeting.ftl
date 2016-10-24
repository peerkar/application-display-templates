<#--

	Demonstration of multi level navigation portlet application display template supporting Audience Targeting.
	===========================================================================================================

	This adds support for from Twitter Bootstrap removed submenu (more than 2 levels). 
	    
	Example is using Liferay Lexicon for styling (http://liferay.github.io/lexicon/content/navbar/#)

	You can use this in site's scope or put in in the global scope application display templates.
	
	In order to make it work you have to give Freemarker engine access to the serviceLocator:
		Go to Control panel / Configuration / System Settings / Freemarker engine and
		remove serviceLocator from Restricted variables list.

	For more information of navigation items properties see the specs for NavItem class:
	https://docs.liferay.com/portal/6.2/javadocs/com/liferay/portal/theme/NavItem.html

	Thanks to Sampsa Sohlman https://gist.github.com/sammso/64f91cb4e1c2968f4fcd7a12fb7e8284
	
-->

<#---------------------------------------------------------------->
<#--Styles														--> 
<#---------------------------------------------------------------->

<style>

	<#-- Make > 2 level submenus visible -->
	
	#p_p_id<@portlet.namespace /> .dropdown-menu {
		overflow: visible;
	}
	
	#p_p_id<@portlet.namespace /> .nav a {
		outline: none !important;
	}
	
</style>

<#---------------------------------------------------------------->
<#--Debugging													--> 
<#---------------------------------------------------------------->

<#assign debug = false />

<#if debug>
	<b>Current userSegmentIds:</b><br />
    <ul>
	    <#if renderRequest.getAttribute("userSegmentIds")?? >
    	    <#list renderRequest.getAttribute("userSegmentIds") as userSegmentId>
      	      <li>${userSegmentId}</li>
      	  </#list>
    </#if>
    </ul>
</#if>

<#---------------------------------------------------------------->
<#-- Can't do targeting if servicelocator is not made available --> 
<#---------------------------------------------------------------->

<#if serviceLocator??>

    <#assign userSegmentLocalService = serviceLocator.findService("com.liferay.content.targeting.service.UserSegmentLocalService")/>
	<#assign assetCategoryLocalService = serviceLocator.findService("com.liferay.asset.kernel.service.AssetCategoryLocalService") />

	<#if renderRequest.getAttribute("originalUserSegmentIds")??>
		<#assign userSegmentIds = renderRequest.getAttribute("originalUserSegmentIds") />
	</#if>	
</#if>

<#---------------------------------------------------------------->
<#-- Check if entry is visible									-->
<#---------------------------------------------------------------->

<#function isVisible entry>

	<#assign visible = true />

	<#if userSegmentIds??>

		<#assign navItemCategoryIds = assetCategoryLocalService.getCategoryIds("com.liferay.portal.kernel.model.Layout", entry.getLayout().getPlid()) />
				
		<#-- Ignore and return true if entry has no categories -->
	
		<#if !navItemCategoryIds?has_content>
			<#return true>
		</#if>

		<#-- Loop user segments -->
		
		<#list userSegmentIds as userSegmentId>

			<#assign userSegmentAssetCategoryId = userSegmentLocalService.getUserSegment(userSegmentId).getAssetCategoryId() />
    
    		<#list navItemCategoryIds as navItemCategoryId>
		
				<#-- Because user segment is a category in itself we have to check if entry is tagged with it (SEO tab) -->
			
				<#if userSegmentAssetCategoryId == navItemCategoryId>
					<#return true />
				<#else>
					
					<#-- Check if this category is another user segment. If it is not then ignore it -->
					
					<#if userSegmentLocalService.fetchUserSegmentByAssetCategoryId(navItemCategoryId)?has_content>
						<#assign visible = false />
					</#if>
				</#if>
			</#list>
		</#list>
	</#if>
		
	<#return visible>	
</#function>		
	
<#---------------------------------------------------------------->
<#-- Build one level											-->
<#---------------------------------------------------------------->

<#macro loopChildren root isSubMenu depth>

	<#list root as entry>

		<#if isVisible(entry)>

			<#assign attrSelected = "" />
			<#assign itemCssClass = "" />

			<#if entry.isSelected() || entry.isChildSelected()>
				<#assign attrSelected = "aria-selected=\"true\"" />
				<#assign itemCssClass = "selected active" />
			</#if>			

			<#if entry.children?has_content && (depth <= displayDepth)>

				<#-- Use Bootstrap dropdown-submenu -->
			
				<#if isSubMenu>
					<li class="dropdown dropdown-submenu ${itemCssClass}" ${attrSelected}>
		    			<a aria-expanded="false" class="dropdown-toggle" data-toggle="dropdown" href="#" role="button">
		    				${entry.getName()} <span class="caret"></span>
		    			</a>
				<#else>
					<li class="dropdown ${itemCssClass}" ${attrSelected}>
		    			<a aria-expanded="false" class="dropdown-toggle" data-toggle="dropdown" href="#" role="button">
		    				${entry.getName()} <span class="caret"></span>
			    		</a>
			    </#if>
				<ul class="dropdown-menu" role="menu">

					<#assign nextDepth = depth + 1 />

					<@loopChildren root=entry.children isSubMenu=true depth=nextDepth />
				</ul>
				</li>

			<#else>					
		   	    <li class="${itemCssClass}" ${attrSelected}>
	    	    	<a href="${entry.getURL()}">${entry.getName()}</a>
    			</li>    
    		</#if>
   		</#if>
	</#list>
</#macro>		

<#---------------------------------------------------------------->
<#-- Main loop													-->
<#---------------------------------------------------------------->

<#if entries?has_content>
	<nav class="navbar navbar-default" role="navigation">
		<ul class="nav navbar-nav">
			<@loopChildren root=entries isSubMenu=false depth=1 />
		</ul>
	</nav>
</#if>

<#---------------------------------------------------------------->
<#-- Dropdown script											-->
<#---------------------------------------------------------------->

<script type="text/javascript">

	/* Set handler for submenu toggler. Isn't supported OOTB in BS 3 */
	
	$('#p_p_id<@portlet.namespace /> .dropdown-submenu .dropdown-toggle').click(function(event) {
		$(this).parent('.dropdown').toggleClass('open');
		event.preventDefault();
		return false;
    });
    
</script>

