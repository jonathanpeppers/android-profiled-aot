namespace MauiBlazorApp1;

public partial class MainPage : ContentPage
{
	public MainPage()
	{
		InitializeComponent();

		_ = CommonMethods.Invoke();
	}
}
