xquery version "1.0" encoding "UTF-8";

module namespace html = 'http://converters.eionet.europa.eu/common/ui/html';

declare function html:getCss() as element(style) {
    <style><![CDATA[
    
        ul.qcMenu li span.errorLevel {
            font-size:0.8em;
            color:white;
        }
        
        ul.qcMenu li span.errorLevel.OK {
            background-color: green;
        }
        
        ul.qcMenu li span.errorLevel.INFO {
            background-color: blue;
        }
        
        ul.qcMenu li span.errorLevel.WARNING {
            background-color: orange;
        }
        
        ul.qcMenu li span.errorLevel.ERROR,
        ul.qcMenu li span.errorLevel.BLOCKER {
            background-color: red;
        }
    
        div.qcSection.OK span.summary {
            color: green;
        }
    
        div.qcSection.INFO span.summary {
            color: blue;
        }
        
        div.qcSection.WARNING span.summary {
            color: orange;
        }
    
        div.qcSection.ERROR span.summary,
        div.qcSection.BLOCKER span.summary {
            color: red;
        }
        
        .green {
            color: green;
            font-weight: bold;
        }
        
        .blue {
            color: blue;
            font-weight: bold;
        }
        
        .orange {
            color: orange;
            font-weight: bold;
        }
        
        .red {
            color: red;
            font-weight: bold;
        }
        
        table, table td, table th {
            border: black solid 1px;
        }
        
        table {
            margin-top: 5px;
            margin-bottom: 5px;
        }
        
        table.dataTable th {
            text-align: center;
        }
        
        table.dataTable td {
            text-align: right;
        }
        
        div.qcDetails table {
            font-size: 0.9em;
        }
        
        table tr.eionet_qc_result_set_truncated td {
            color: red;
            font-style: italic;
            font-weight: bold;
            text-align: left;
        }
        
    ]]>
    </style>
};

declare function html:getJavascript() as element(script) {
    <script type="text/javascript"><![CDATA[
                        
        (function () {

            var ChecklistState = {
                CLEAR: 0,
                MIXED: 1,
                ALL: 2
            };
    
            var SHOW_ALL_LABEL = 'Show all records';
            var HIDE_ALL_LABEL = 'Hide all records';
    
            window.onColumnCheckboxCheck = function (checkbox) {
                var checkboxContainer = getParentByElementName(checkbox, 'table');
                var visibleRowClassResult = getVisibleRowClasses(checkboxContainer);
                var dataArea = getDataAreaForQc(visibleRowClassResult.qcId);
                var toggleButton = getToggleButtonForQc(visibleRowClassResult.qcId);
    
                if (visibleRowClassResult.columnIds.length === 0) {
                    dataArea.style.display = 'none';
                    toggleButton.value = SHOW_ALL_LABEL;
                    return;
                }
    
                var dataTable = getDataTableForQc(visibleRowClassResult.qcId);
                markVisibleRows(dataTable, visibleRowClassResult.columnIds);
                var additionalTable = getAdditionalTableForQc(visibleRowClassResult.qcId);
                
                if (additionalTable) {
                    markVisibleRows(additionalTable, visibleRowClassResult.columnIds);
                }
                
                dataArea.style.display = 'block';
    
                if (visibleRowClassResult.checklistState === ChecklistState.ALL) {
                    toggleButton.value = HIDE_ALL_LABEL;
                }
                else {
                    toggleButton.value = SHOW_ALL_LABEL;
                }
            };
    
            window.onToggleButtonClick = function (toggleButton) {
                var hide = toggleButton.value === HIDE_ALL_LABEL;
                var qcId = parseToggleButtonId(toggleButton).qcId;
                var checkboxContainer = getCheckboxContainerForQc(qcId);
    
                if (checkboxContainer) {
                    var checkboxes = checkboxContainer.getElementsByTagName('input');
    
                    for (var i = 0; i !== checkboxes.length; i++) {
                        checkboxes[i].checked = !hide;
                    }
    
                    window.onColumnCheckboxCheck(checkboxes[0]);
                }
                else {
                    var dataArea = getDataAreaForQc(qcId);
                    dataArea.style.display = hide ? 'none' : 'block';
                }
    
                toggleButton.value = hide ? SHOW_ALL_LABEL : HIDE_ALL_LABEL;
            };
    
            function getParentByElementName(element, parentElementName) {
                var nodeName = parentElementName.toLowerCase();
                var parent = element;
    
                do {
                    parent = parent.parentNode;
                    
                    if (!parent) {
                        break;
                    }
                }
                while (nodeName !== parent.nodeName.toLowerCase());
    
                return parent;
            }
    
            function getChildrenByElementName(element, childElementName) {
                var elementNameToSearch = childElementName.toLowerCase();
                var result = [];
    
                for (var i = 0; i !== element.children.length; i++) {
                    var child = element.children[i];
    
                    if (child.nodeName.toLowerCase() === elementNameToSearch) {
                        result.push(child);
                    }
                }
    
                return result;
            }
    
            function getVisibleRowClasses(checkboxContainer) {
                var result = {
                    qcId: parseCheckboxContainerId(checkboxContainer).qcId,
                    columnIds: []
                };
                var checkboxes = checkboxContainer.getElementsByTagName('input');
                var checkCount = 0;
    
                for (var i = 0; i !== checkboxes.length; i++) {
                    var checkbox = checkboxes[i];
    
                    if (!checkbox.checked)
                        continue;
    
                    checkCount++;
                    var checkboxMeta = parseCheckboxId(checkbox);
                    result.columnIds.push(checkboxMeta.columnId);
                }
    
                if (checkCount === 0) {
                    result.checklistState = ChecklistState.CLEAR;
                }
                else if (checkCount === checkboxes.length) {
                    result.checklistState = ChecklistState.ALL;
                }
                else {
                    result.checklistState = ChecklistState.MIXED;
                }
    
                return result;
            }
    
            function parseCheckboxContainerId(checkboxContainer) {
                var idTokens = checkboxContainer.id.split('_');
    
                return {
                    qcId: idTokens[1]
                };
            }
    
            function parseCheckboxId(checkbox) {
                var idTokens = checkbox.id.split('_');
    
                return {
                    qcId: idTokens[1],
                    columnId: idTokens.slice(2).join('_')
                };
            }
    
            function parseToggleButtonId(toggleButton) {
                var idTokens = toggleButton.id.split('_');
    
                return {
                    qcId: idTokens[1]
                };
            }
    
            function getCheckboxContainerForQc(qcId) {
                return document.getElementById('checkboxTable_' + qcId);
            }
    
            function getToggleButtonForQc(qcId) {
                return document.getElementById('toggleButton_' + qcId);
            }
    
            function getDataAreaForQc(qcId) {
                return document.getElementById('dataarea_' + qcId);
            }
    
            function getDataTableForQc(qcId) {
                return document.getElementById('datatable_' + qcId);
            }
            
            function getAdditionalTableForQc(qcId) {
                return document.getElementById('additionalTable_' + qcId);
            }
    
            function markVisibleRows(dataTable, visibleRowClassNames) {
                var rows = getDataRows(dataTable);
    
                for (var i = 0; i !== rows.length; i++) {
                    var row = rows[i];
                    
                    if (!canMarkRow(row)) {
                        continue;
                    }
                    
                    var rowDisplay;
    
                    if (containsAtLeastOneClassName(row, visibleRowClassNames)) {
                        rowDisplay = 'table-row';
                    }
                    else {
                        rowDisplay = 'none';
                    }
    
                    row.style.display = rowDisplay;
                }
            }
    
            function getDataRows(dataTable) {
                var dataBody = getChildrenByElementName(dataTable, 'tbody')[0];
                return getChildrenByElementName(dataBody, 'tr');
            }
            
            function canMarkRow(dataRow) {
                return dataRow.className !== "eionet_qc_result_set_truncated";
            }
            
            function containsAtLeastOneClassName(htmlElement, classNames) {
                var elementClassNames = htmlElement.className.split(' ');
    
                for (var i = 0; i !== classNames.length; i++) {
                    if (arrayIndexOf(elementClassNames, classNames[i]) !== -1) {
                        return true;
                    }
                }
    
                return false;
            }
    
            function arrayIndexOf(array, item) {
                for (var i = 0; i !== array.length; i++) {
                    if (array[i] === item) {
                        return i;
                    }
                }
    
                return -1;
            }
    
        })();
        
    ]]>
    </script>
};

