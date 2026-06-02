{# Voorbeeldmacro: zet centen om naar euro's/dollars met afronding. #}
{% macro cents_to_dollars(column_name, scale=2) %}
    round(1.0 * {{ column_name }} / 100, {{ scale }})
{% endmacro %}
