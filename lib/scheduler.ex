defmodule Scheduler do

  def run(num_processes, module, func, input_data_queue) do
    (1..num_processes)
    |> Enum.map(fn _ -> spawn(module, func, [self()]) end)
    |> schedule_processes(input_data_queue, [])
  end

  defp schedule_processes(processes, input_data_queue, results) do
    receive do
      
      {:ready, pid} when input_data_queue != [] ->
        [next | tail] = input_data_queue
        send pid, {next, self()}
        schedule_processes(processes, tail, results)
      
      {:ready, pid} ->
        send pid, {:shutdown}
        if (length(processes) > 1) do
          schedule_processes(List.delete(processes, pid), input_data_queue, results)
        else
          results
        end
        
      {:answer, result, _pid} ->
        schedule_processes(processes, input_data_queue, [result | results])
    end
  end

end