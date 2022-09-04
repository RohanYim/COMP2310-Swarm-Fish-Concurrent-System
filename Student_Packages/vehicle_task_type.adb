-- Suggestions for packages which might be useful:

with Ada.Real_Time;              use Ada.Real_Time;

with Exceptions;                 use Exceptions;
with Real_Type;                  use Real_Type;
with Vectors_3D;                 use Vectors_3D;
with Vehicle_Interface;          use Vehicle_Interface;
with Vehicle_Message_Type;       use Vehicle_Message_Type;
with Swarm_Structures;           use Swarm_Structures;
with Swarm_Structures_Base; use Swarm_Structures_Base;
with get_positions; use get_positions;

package body Vehicle_Task_Type is

   task body Vehicle_Task is
      Vehicle_No : Positive; pragma Unreferenced (Vehicle_No);
--        Local_Task_Id : Task_Id;
      Message_from_car : Inter_Vehicle_Messages;
      Message_for_charge : Inter_Vehicle_Messages;
      Get_Message_from_Car : Inter_Vehicle_Messages;
      waiting_speed            : constant Throttle_T := 0.2;
      find_globe_Throttle : constant Throttle_T := 0.4;
      Lastest_Time : Time := Clock;

      -- You will want to take the pragma out, once you use the "Vehicle_No"

   begin

      -- You need to react to this call and provide your task_id.
      -- You can e.g. employ the assigned vehicle number (Vehicle_No)
      -- in communications with other vehicles.

      accept Identify (Set_Vehicle_No : Positive; Local_Task_Id : out Task_Id) do
         Vehicle_No     := Set_Vehicle_No;
         Local_Task_Id  := Current_Task;
      end Identify;

      -- Replace the rest of this task with your own code.
      -- Maybe synchronizing on an external event clock like "Wait_For_Next_Physics_Update",
      -- yet you can synchronize on e.g. the real-time clock as well.

      -- Without control this vehicle will go for its natural swarming instinct.

      select

         Flight_Termination.Stop;

      then abort

         Outer_task_loop : loop

            Wait_For_Next_Physics_Update;
            declare
               Globes      : constant Energy_Globes := Energy_Globes_Around;
               to_which : Integer;

               -- Your vehicle should respond to the world here: sense, listen, talk, act?
            begin
               -- if I can find a globe
               if Globes'Size > 0 then
                  -- get all globes
                  for i in Globes'Range loop
                     Message_from_car.Globe (i) := Globes (i);
                  end loop;
                  Message_from_car.Globe_num := Globes'Length;
                  Message_from_car.Get_Time := Clock;
                  Message_from_car.V_charge := Current_Charge;
--                    Message_from_car.V_id := Vehicle_No;
                  Send (Message => Message_from_car);
                  -- if I got enough charge, do nothing
                  if Current_Charge > 0.5 then
                     Set_Throttle (T => waiting_speed);
                  -- if I need to charge, compare if I am the most urgent one
                  else
                     while Messages_Waiting loop
                        Receive (Message => Message_for_charge);
                        -- update the latest globe position
                        if Ada.Real_Time.">="(Left  => Message_for_charge.Get_Time, Right => Lastest_Time) then
                           Lastest_Time := Message_for_charge.Get_Time;
                           Message_from_car.Globe := Message_for_charge.Globe;
                           Message_from_car.Globe_num := Message_for_charge.Globe_num;
                           Message_from_car.Get_Time := Lastest_Time;
                           Message_from_car.V_charge := Current_Charge;
                        end if;
                     end loop;
                     Send (Message => Message_from_car);
                     -- yes I am not the urgent one, do nothing
                     if Message_for_charge.V_charge < Current_Charge then
                        Set_Throttle (T => waiting_speed);
                     -- no, go charging
                     else
                        -- avoid collision near the globe
                        select
                           -- the less charge I have, the less delay time I get
                           delay Duration (0.01 * (Real (Current_Charge)) / (Current_Discharge_Per_Sec));
                        then abort
                           -- find the nearest globe
                           to_which := Protected_Element.find_nearest_globe (Position, Message_from_car.Globe, Message_from_car.Globe_num);
                           Set_Throttle (T => Full_Throttle);
                           Set_Destination (V => Message_from_car.Globe (to_which).Position);
                        end select;

                     end if;
                  end if;
               -- if I can't find a globe
               else
                  -- if I need to charge
                  if Current_Charge < 0.5 then
                     -- go charging
                     while Messages_Waiting loop
                        Receive (Message => Get_Message_from_Car);
                        if Ada.Real_Time.">="(Left  => Get_Message_from_Car.Get_Time, Right => Lastest_Time) then
                           Lastest_Time := Get_Message_from_Car.Get_Time;
                           Message_from_car.Globe_num := Get_Message_from_Car.Globe_num;
                           Message_from_car.Globe := Get_Message_from_Car.Globe;
                           Message_from_car.Get_Time := Lastest_Time;
                           Message_from_car.V_charge := Current_Charge;
                        end if;
                     end loop;
                     -- send message to help others
                     Send (Message => Get_Message_from_Car);
                     Set_Throttle (T => Full_Throttle);
                     select
                        delay Duration (0.01 * (Real (Current_Charge)) / (Current_Discharge_Per_Sec));
                     then abort
                        -- find the nearest globe
                        to_which := Protected_Element.find_nearest_globe (Position, Message_from_car.Globe, Message_from_car.Globe_num);
                        Set_Destination (V => Message_from_car.Globe (to_which).Position);
                     end select;
                  -- if I got enough charge
                  else
                     --move and try to find the globe myself
                     -- find the nearest globe
                     while Messages_Waiting loop
                        Receive (Message => Get_Message_from_Car);
                        if Ada.Real_Time.">="(Left  => Get_Message_from_Car.Get_Time, Right => Lastest_Time) then
                           Lastest_Time := Get_Message_from_Car.Get_Time;
                           Message_from_car.Globe := Get_Message_from_Car.Globe;
                           Message_from_car.Globe_num := Get_Message_from_Car.Globe_num;
                           Message_from_car.Get_Time := Lastest_Time;
                           Message_from_car.V_charge := Current_Charge;
                        end if;
                     end loop;
                     -- send message to help others
                     Send (Message => Message_from_car);
                     Set_Throttle (T => find_globe_Throttle);
                     to_which := Protected_Element.find_nearest_globe (Position, Message_from_car.Globe, Message_from_car.Globe_num);
                     Set_Destination (V => Message_from_car.Globe (to_which).Position);
                  end if;

               end if;

            end;

         end loop Outer_task_loop;

      end select;

   exception
      when E : others => Show_Exception (E);

   end Vehicle_Task;

end Vehicle_Task_Type;
