#!/bin/bash

# ---- ARQUIVOS DE APOIO CRIADOS PELO SCRIPT ----
#
# Arquivo: procs.txt: Contém informações dos processos em execução atualmente
# Arquivo: update.txt: Contém um valor (1 ou 0) que indica se a tela ficará sendo atualizada(1) ou não(0)
#
# -----------------------------------------------  

UPDATE_INTERVAL=5


function update_procs(){
	# salvando informações de processos
	ps aux | sort -rk 9 | tr -s " " | tr -d "<>" > procs.txt

	# formatando informações de processos
	echo "$( awk -f procformat.awk < procs.txt )" > procs.txt

	cat procs.txt
}

function update_screen(){
	while [ -f update.txt ] 
	do
		if [ "$( cat update.txt )" -eq 1 ]
		then
			echo -e "\f"
			update_procs
			sleep ${UPDATE_INTERVAL}
		fi
	done
}

function set_update_screen(){
	# ativa: $1 = 1
	# desativa: $1 = 0

	echo "$1" > update.txt
}

function plot_chart(){
	# TODO: plotar gráfico
	echo
}

function kill_proc(){
	# TODO: matar processo
	./$0
}

function main(){

	export -f set_update_screen
	export -f plot_chart
	export -f kill_proc

	set_update_screen 1

	GUI=$( yad --list				\
	--title="ProcView - Process Viewer"		\
	--width=700 --height=700 --center --on-top	\
	--window-icon="icon.ico"			\
	--dclick-action="bash -c 'plot_chart %s'"	\
	--grid-lines="both"				\
	--column="@fore@"				\
	--column="@back@"				\
	--column="PID:NUM"				\
	--column="User:TEXT" 				\
	--column="CPU(%):FLT" 				\
	--column="RAM(%):FLT" 				\
	--column="VSZ:SZ"				\
	--column="RSS:SZ" 				\
	--column="Start:TEXT" 				\
	--column="Comand:TEXT"				\
	--button="Stop:bash -c 'set_update_screen 0'" 	\
	--button="Start:bash -c 'set_update_screen 1'"	\
	--button="Filter by user:ls"			\
	--button="Start process:ls"	    		\
	--button="Schedule process:ls"			\
	--button="Kill:0" < <( update_screen )&
	)

	# removendo arquivos desnescessários
	rm -f procs.txt update.txt

	# Se saída da GUI for não vazia, um processo 
	# foi especificado para ser morto.
	# Senão, o processo atual será morto 
	[ -n "${GUI}" ] && kill_proc ${GUI}
}

main &> /dev/null

