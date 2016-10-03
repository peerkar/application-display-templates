<#--
    Demonstration of using Application Display Templates in Navigation Portlet 
-->

<#if entries?has_content>
	<ul class="custom-navigation-menu">
		<@loopChildren root=entries />
	</ul>
</#if>

<#macro loopChildren root>
	<ul>
		<#list root as entry>
			<li><a href="${entry.getURL()}">${entry.getName()}</a>
				<#if entry.children?has_content>
					<@loopChildren root=entry.children />
				</#if>    
			</li>
		</#list>
	</ul>
</#macro>
