{% macro gen_country_name(country_code) %}
    CASE 
        WHEN country_code = 'AIN' THEN 'Athlètes Individuels Neutres'
        ELSE country 
    END as country
{% endmacro %}