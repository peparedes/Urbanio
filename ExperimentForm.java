import javax.swing.BoxLayout;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JComboBox;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JTextField;
import javax.swing.SpringLayout;

import java.awt.HeadlessException;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.io.File;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;

import jssc.*;

import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;


public class ExperimentForm extends JFrame implements ActionListener {
	JPanel mainPanel;
	JLabel modeLabel;
	JLabel TrialLabel;
	JLabel softHardLabel;
	JTextField softHardField;
	JComboBox modeList;
	JTextField modeField;
	JTextField TrialIdField;
	JLabel titleLabel;
	JButton startButton;
	SerialPort serialPort;
	
	int chosenMode;
	int intensity;
	String trialIDInput;
	
	public ExperimentForm() throws HeadlessException{
		serialPort = new SerialPort("/dev/tty.usbmodem1422"); //set serial port
		
		mainPanel = new JPanel();
		mainPanel.setLayout(new BoxLayout(mainPanel, BoxLayout.Y_AXIS));
		titleLabel = new JLabel("UrbanIO Experiment", JLabel.CENTER);
		startButton = new JButton("Start Run");
		startButton.addActionListener(this);
		startButton.setToolTipText("Click to Start Run");

		modeField = new JTextField(10);
		TrialIdField = new JTextField(10);
		softHardField = new JTextField(10);
		modeLabel = new JLabel("Mode: (1=Before, 2=During, 3=After, 4=Random, 5=Nothing)", JLabel.TRAILING);
		
		String[] modeArr = { "1. Before", "2. During", "3. After",
				"4. Random", "5. Nothing"};
		modeList = new JComboBox(modeArr);
		
		TrialLabel = new JLabel("Trial No:", JLabel.TRAILING);
		softHardLabel = new JLabel("Smooth or Sharp (1 or 2):", JLabel.HORIZONTAL);
		
		mainPanel.add(titleLabel);
		mainPanel.add(modeLabel);
		modeLabel.setLabelFor(modeField);
		mainPanel.add(modeField);

		mainPanel.add(TrialLabel);
		TrialLabel.setLabelFor(TrialIdField);
		mainPanel.add(TrialIdField);
		
		mainPanel.add(softHardLabel);
		softHardLabel.setLabelFor(softHardField);
		mainPanel.add(softHardField);
		mainPanel.add(startButton);
		

		this.setContentPane(mainPanel);
		this.setSize(300, 100);
		this.setVisible(true);
		this.pack();
		this.setResizable(true);
		this.setLocationRelativeTo(null);
		this.setDefaultCloseOperation(this.EXIT_ON_CLOSE);	
	}
	
	@Override
	public void actionPerformed(ActionEvent event) {
		if (event.getSource() == startButton) {
			if(startButton.getText().equals("Start Run"))
			{	
				chosenMode = Integer.parseInt(modeField.getText()) + 48;
				intensity = Integer.parseInt(softHardField.getText()) + 48;
				trialIDInput = TrialIdField.getText();

				startButton.setText("Stop Run");
				startButton.setToolTipText("Click to Stop the Run");
				
				 try {
			            serialPort.openPort();//Open serial port
			            serialPort.setParams(SerialPort.BAUDRATE_9600, 
			                                 SerialPort.DATABITS_8,
			                                 SerialPort.STOPBITS_1,
			                                 SerialPort.PARITY_NONE);//Set params. Also you can set params by this string: serialPort.setParams(9600, 8, 1, 0);
			            
			            
			            
			            
			            System.out.println(serialPort.readString());
			            
			            
			            serialPort.writeInt(intensity);//Write intensity to port
			            
			            
			            try {
			                Thread.sleep(1000);                 //1000 milliseconds is one second.
			            } catch(InterruptedException ex) {
			                Thread.currentThread().interrupt();
			            }
			            System.out.println(serialPort.readString());
			            
			            
			            serialPort.writeInt(chosenMode); //write mode to port
			            
			            try {
			                Thread.sleep(1000);                 //1000 milliseconds is one second.
			            } catch(InterruptedException ex) {
			                Thread.currentThread().interrupt();
			            }
			            System.out.println(serialPort.readString());
			            
			            
			            
			            
			            serialPort.writeInt(49); //write "Ready"
			            try {
			                Thread.sleep(1000);                 //1000 milliseconds is one second.
			            } catch(InterruptedException ex) {
			                Thread.currentThread().interrupt();
			            }
			            System.out.println(serialPort.readString());
			            
			            //create new file
			            try{ //for creating a file
				            File file = new File("UrbanIO_data.txt");
				            //if file doesnt exists, then create it
				    		if(!file.exists()){
				    			file.createNewFile();
				    		}
				    		FileWriter fileWritter = new FileWriter(file,true);
			    	        BufferedWriter bufferWritter = new BufferedWriter(fileWritter);
			    	      
			    	        bufferWritter.write("New Run: ");
			    	        DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
							   //get current date time with Date()
							Date date = new Date();
							bufferWritter.write("" + dateFormat.format(date) + "\n");
							bufferWritter.write(trialIDInput + "\n");
							bufferWritter.write("Lights are: ");
							if (intensity == 49) {
								bufferWritter.write("Smooth\n");
							} else if (intensity == 50) {
								bufferWritter.write("Sharp\n");
							}
							switch(chosenMode) {
							case(49):
								bufferWritter.write("Mode: Before\n");
								break;
							case(50):
								bufferWritter.write("Mode: During\n");
								break;
							case(51):
								bufferWritter.write("Mode: After\n");
								break;
							case(52):
								bufferWritter.write("Mode: Random\n");
								break;
							case(53):
								bufferWritter.write("Mode: Nothing\n");
								break;
							default:
								break;
							}
			    	        
			    	        
			    	        
				            
				            for (int i = 0; i < 50; i++) {
				            	String outputMbed = serialPort.readString();
				            	System.out.println(outputMbed);
				            	//check what output mbed says and write to csv if necessary
				            	if (outputMbed != null && outputMbed.contains("velocity")) { //EDIT BASED ON EXP
				            		bufferWritter.write(outputMbed);
				            		System.out.println("velocity hit");
				            		bufferWritter.close();
				            		break;
				            	} else if (i > 40) {
				            		bufferWritter.write("No data recieved\n");
				            		bufferWritter.close();
				            		break;
				            	}
				            	 try { 	
						                Thread.sleep(1000);                 //1000 milliseconds is one second.
						            } catch(InterruptedException ex) {
						                Thread.currentThread().interrupt();
						            }
				            }
				            
			            }
			            catch(IOException ex) { //for creating a file
			            	System.out.println(ex);
			            }
			            serialPort.closePort();//Close serial port
			            //System.out.println("Intensity sent to SerialPort: " + intensity);
			            //System.out.println("Mode sent to SerialPort: " + chosenMode);
			            
			        }
			        catch (SerialPortException ex) {
			            System.out.println(ex);
			        }

			}
			
			else if(startButton.getText().equals("Stop Run"))
			{
				startButton.setText("Start Run");
				modeField.setText("");
				softHardField.setText("");
				TrialIdField.setText("");
				startButton.setToolTipText("Click to Start the Run");
			}
		}	
	}

	public static void main(String[] args) {
		 //  /dev/tty.usbmodem1422
		/*String[] portNames = SerialPortList.getPortNames();
		if (portNames.length == 0) {
		    System.out.println("There are no serial-ports :( You can use an emulator, such ad VSPE, to create a virtual serial port.");
		    System.out.println("Press Enter to exit...");
		    try {
		        System.in.read();
		    } catch (IOException e) {
		         // TODO Auto-generated catch block
		          e.printStackTrace();
		    }
		    return;
		}
		for (int i = 0; i < portNames.length; i++){
		    System.out.println(portNames[i]);
		} */
		
		/*
		try {
            serialPort.openPort();//Open serial port
            serialPort.setParams(9600, 8, 1, 0);//Set params.
            byte[] buffer = serialPort.readBytes(10);//Read 10 bytes from serial port
            serialPort.closePort();//Close serial port
        }
        catch (SerialPortException ex) {
            System.out.println(ex);
        }
		*/
		new ExperimentForm(); 	
	}
}
