<#function stringify object={} maxDepth=20>
    <#return _encode(object, 0, maxDepth) />
</#function>

<#function _encode object depth maxDepth>
    <#if maxDepth gt 0 && depth gt maxDepth>
        <#local object = '[[refering path depth exceeded]]' />
    </#if>

    <#local jsonStr = '' />

    <#-- string -->
    <#if object?is_string>

        <#if object?contains('@') && (object?is_hash || object?is_hash_ex) && object.hashCode?? && object.class??>
            <#-- javaBean -->
            <#-- javaBean is wrapped in extended_hash + string -->
            <#local jsonStr = jsonStr + '{' />

            <#local keys = [] />
            <#list object?keys as key>
                <#if  key != 'class' && !((object[key]!'')?is_method)>
                    <#local keys = keys + [key] />
                </#if>
            </#list>
            <#list keys as key>
                <#if !object[key]??>
                    <#local jsonStr = jsonStr + '"${key?json_string}":' + 'null' + key_has_next?string(',','') />
                <#else>
                    <#local jsonStr = jsonStr + '"${key?json_string}":' + _encode(object[key], depth+1, maxDepth) + key_has_next?string(',','') />
                </#if>
            </#list>
            <#local jsonStr = jsonStr + '}' />

        <#else>
            <#local jsonStr = '"${object?json_string}"' />
        </#if>


    <#-- number -->
    <#elseif object?is_number>
        <#local jsonStr = object?c />
        <#if jsonStr == 'NaN'> <#-- Number.NaN -->
            <#local jsonStr = 'null' />
        </#if>

    <#-- boolean -->
    <#elseif object?is_boolean>
        <#local jsonStr = object?string('true','false') />
    
    <#-- date -->
    <#elseif object?is_date_like>
        <#local jsonStr = '"${object?datetime?iso_utc_ms}"' />

    <#-- macro -->
    <#elseif object?is_macro>
        <#local jsonStr = '"[[MACRO]]"' />
    
    <#-- function -->
    <#elseif object?is_method>
        <#local jsonStr = '"[[METHOD]]"' />

    <#-- function -->
    <#elseif object?is_directive>
        <#local jsonStr = '"[[DIRECTIVE]]"' />

    <#-- unknown -->
    <#elseif object?is_hash || object?is_hash_ex>
        <#local jsonStr = jsonStr + '{' />
        
        <#list object?keys as key>
            <#if !object[key]??>
                <#local jsonStr = jsonStr + '"${key?json_string}":' + 'null' + key_has_next?string(',','') />
            <#else>
                <#local jsonStr = jsonStr + '"${key?json_string}":' + _encode(object[key], depth+1, maxDepth) + key_has_next?string(',','') />
            </#if>
        </#list>

        <#local jsonStr = jsonStr + '}' />
    
    <#-- sequence -->
    <#elseif object?is_sequence || object?is_collection || object?is_enumerable || object?is_indexable>
        <#local jsonStr = jsonStr + '[' />
        <#list object as item>
            <#if !item??>
                <#local jsonStr = jsonStr + 'null' + item_has_next?string(',','') />
            <#else>
                <#local jsonStr = jsonStr + _encode(item!{}, depth+1, maxDepth) + item_has_next?string(',','') />
            </#if>
        </#list>
        <#local jsonStr = jsonStr + ']' />
    
    <#-- unknown -->
    <#else>
        <#local jsonStr = '"[[UNKNOWN]]"' />

    </#if> 

    <#return jsonStr />
</#function>